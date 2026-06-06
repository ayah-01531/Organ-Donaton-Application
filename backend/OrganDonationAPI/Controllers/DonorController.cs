using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrganDonationAPI.DTOs;
using OrganDonationAPI.Models;
using OrganDonationAPI.Services;
using System.Net;
using System.Security.Claims;
using System.Text.Json;
using OrganDonationAPI.Data;

[ApiController]
[Route("api/[controller]")]
public class DonorController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IWebHostEnvironment _env;
    private readonly IEmailService _emailService;

    public DonorController(
        AppDbContext context,
        UserManager<ApplicationUser> userManager,
        IWebHostEnvironment env,
        IEmailService emailService)
    {
        _context = context;
        _userManager = userManager;
        _env = env;
        _emailService = emailService;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterDonorDto dto)
    {
        var existing = await _userManager.FindByEmailAsync(dto.Email);
        if (existing != null)
            return BadRequest(new { message = "Email already in use." });

        var user = new ApplicationUser
        {
            FullName = dto.FullName,
            Email = dto.Email,
            UserName = dto.Email,
            Role = "Donor"
        };

        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
            return BadRequest(result.Errors);

        await _userManager.AddToRoleAsync(user, "Donor");

        //  إرسال إيميل التأكيد
        var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
        var encodedToken = WebUtility.UrlEncode(token);
        var confirmUrl = $"{Request.Scheme}://{Request.Host}/api/auth/confirm-email?userId={user.Id}&token={encodedToken}";

        await _emailService.SendAsync(
    dto.Email,
    "تأكيد إيميلك - نظام التبرع بالأعضاء",
    _emailService.ConfirmationEmailBody(dto.FullName, confirmUrl)
);
        return Ok(new { message = "تم التسجيل بنجاح. تحقق من إيميلك لتفعيل حسابك." });
    }

    [HttpPost("apply")]
    [Authorize]
    public async Task<IActionResult> ApplyDonor([FromBody] DonorApplicationDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (userId == null)
            return Unauthorized();

        //  تأكد إن الإيميل مؤكد قبل ما يقدم طلب
        var user = await _userManager.FindByIdAsync(userId);
        if (user != null && !await _userManager.IsEmailConfirmedAsync(user))
            return BadRequest(new { message = "يرجى تأكيد إيميلك أولاً قبل تقديم الطلب." });

        var existingDonor = await _context.Donors.FirstOrDefaultAsync(d => d.UserId == userId);
        if (existingDonor != null)
            return BadRequest(new { message = "You have already submitted a donor application." });

        var donor = new Donor
        {
            UserId = userId,
            FullName = dto.FullName,
            NationalId = dto.NationalId,
            BloodType = dto.BloodType,
            DateOfBirth = dto.DateOfBirth,
            Address = dto.Address,
            PhoneNumber = dto.PhoneNumber,
            OrgansToDonat = JsonSerializer.Serialize(dto.OrgansToDonat),
            MedicalConditions = dto.MedicalConditions,
            MedicalReportsPath = dto.MedicalReportsPath,
            Status = "Pending"
        };

        _context.Donors.Add(donor);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Donor application submitted successfully, awaiting Ministry approval." });
    }

    [HttpGet("my-status")]
    [Authorize(Roles = "Donor")]
    public async Task<IActionResult> MyStatus()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var donor = await _context.Donors
            .FirstOrDefaultAsync(d => d.UserId == userId);

        if (donor == null)
            return NotFound(new { message = "No application found." });

        return Ok(new
        {
            donor.Id,
            donor.FullName,
            donor.NationalId,
            donor.BloodType,
            donor.Address,
            donor.Status,
            donor.RegisteredAt,
            organs = JsonSerializer.Deserialize<List<string>>(donor.OrgansToDonat)
        });
    }

    [HttpPost("upload-medical-report")]
    [Authorize(Roles = "Donor")]
    public async Task<IActionResult> UploadMedicalReport(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "No file uploaded." });

        var allowedExtensions = new[] { ".pdf", ".jpg", ".jpeg", ".png" };
        var extension = Path.GetExtension(file.FileName).ToLower();
        if (!allowedExtensions.Contains(extension))
            return BadRequest(new { message = "Only PDF, JPG, PNG files are allowed." });

        if (file.Length > 5 * 1024 * 1024)
            return BadRequest(new { message = "File size must be less than 5MB." });

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "medical-reports");
        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var uniqueFileName = $"{Guid.NewGuid()}{extension}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var relativePath = $"/uploads/medical-reports/{uniqueFileName}";
        return Ok(new { path = relativePath, message = "File uploaded successfully." });
    }

    [HttpGet("search")]
    [Authorize(Roles = "HospitalAdmin")]
    public async Task<IActionResult> SearchDonor([FromQuery] string nationalId)
    {
        if (string.IsNullOrWhiteSpace(nationalId))
            return BadRequest(new { message = "الرقم الوطني مطلوب" });

        var donor = await _context.Donors
            .FirstOrDefaultAsync(d => d.NationalId == nationalId);

        if (donor == null)
            return NotFound(new { message = "لا يوجد متبرع مسجل بهذا الرقم الوطني" });

        return Ok(new
        {
            fullName = donor.FullName,
            nationalId = donor.NationalId,
            email = donor.User?.Email,
            phoneNumber = donor.PhoneNumber,
            bloodType = donor.BloodType,
            address = donor.Address,
            dateOfBirth = donor.DateOfBirth,
            status = donor.Status,
            organsToDonat = JsonSerializer.Deserialize<List<string>>(donor.OrgansToDonat),
            medicalConditions = donor.MedicalConditions
        });
    }

    [HttpPost("mark-deceased")]
    [Authorize(Roles = "HospitalAdmin")]
    public async Task<IActionResult> MarkAsDeceased(
        [FromForm] string nationalId,
        IFormFile deathCertificate)
    {
        if (string.IsNullOrWhiteSpace(nationalId))
            return BadRequest(new { message = "الرقم الوطني مطلوب" });

        if (deathCertificate == null || deathCertificate.Length == 0)
            return BadRequest(new { message = "شهادة الوفاة مطلوبة" });

        var donor = await _context.Donors
            .FirstOrDefaultAsync(d => d.NationalId == nationalId);

        if (donor == null)
            return NotFound(new { message = "لا يوجد متبرع بهذا الرقم" });

        if (donor.Status == "Deceased")
            return BadRequest(new { message = "تم تسجيل الوفاة مسبقاً" });

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? "wwwroot", "uploads", "death-certificates");
        Directory.CreateDirectory(uploadsFolder);

        var fileName = $"{nationalId}_{Guid.NewGuid()}{Path.GetExtension(deathCertificate.FileName)}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
            await deathCertificate.CopyToAsync(stream);

        donor.Status = "Deceased";
        donor.DeathCertificatePath = filePath;
        donor.DateOfDeath = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return Ok(new { message = "تم تسجيل الوفاة بنجاح" });
    }
}
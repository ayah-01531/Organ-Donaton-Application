using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrganDonationAPI.Data;
using OrganDonationAPI.DTOs;
using OrganDonationAPI.Models;
using OrganDonationAPI.Services;
using System.Net;
using System.Security.Claims;

[ApiController]
[Route("api/[controller]")]
public class HospitalController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IEmailService _emailService;

    public HospitalController(
        AppDbContext context,
        UserManager<ApplicationUser> userManager,
        IEmailService emailService)
    {
        _context = context;
        _userManager = userManager;
        _emailService = emailService;
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> Dashboard()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var hospitalId = await _context.Hospitals
            .FirstOrDefaultAsync(h => h.UserId == userId);

        var totalApprovedDonors = await _context.Donors
            .CountAsync(d => d.Status == "Approved");

        var pendingDonors = await _context.Donors
            .CountAsync(d => d.Status == "Pending");

        var waitingPatients = await _context.PatientNeeds
            .CountAsync(p => p.HospitalId == hospitalId.Id && p.Status == "Waiting");

        return Ok(new
        {
            waitingPatientsInHospital = waitingPatients,
            totalApprovedDonors,
            pendingDonors
        });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterHospitalDto dto)
    {
        // التحقق من الإيميل
        var existingUser = await _userManager.FindByEmailAsync(dto.Email);
        if (existingUser != null)
            return BadRequest(new { message = "Email already in use." });

        // التحقق من رقم الترخيص
        var existingLicense = await _context.Hospitals
            .AnyAsync(h => h.LicenseNumber == dto.LicenseNumber);
        if (existingLicense)
            return BadRequest(new { message = "License Number already in use." });

        var user = new ApplicationUser
        {
            UserName = dto.Email,
            FullName = dto.HospitalName,
            Email = dto.Email,
            LicenseNumber = dto.LicenseNumber,
            Role = "HospitalAdmin"
        };

        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });

        await _userManager.AddToRoleAsync(user, AppRoles.HospitalAdmin);

        var hospital = new Hospital
        {
            UserId = user.Id,
            Name = dto.HospitalName,
            Email = dto.Email,
            LicenseNumber = dto.LicenseNumber,
            Status = "Pending",
            IsApprovedByMinistry = false,
            CreatedAt = DateTime.UtcNow
        };

        _context.Hospitals.Add(hospital);
        await _context.SaveChangesAsync();

        var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
        var encodedToken = WebUtility.UrlEncode(token);
        var confirmUrl = $"{Request.Scheme}://{Request.Host}/api/auth/confirm-email?userId={user.Id}&token={encodedToken}";

        await _emailService.SendAsync(
            dto.Email,
            "تأكيد إيميل المستشفى - نظام التبرع بالأعضاء",
            $@"
            <div style='font-family: Arial; direction: rtl; padding: 20px;'>
                <h2>مرحباً {dto.HospitalName} 🏥</h2>
                <p>تم استلام طلب تسجيل مستشفاكم في نظام التبرع بالأعضاء.</p>
                <p>اضغط على الزر أدناه لتأكيد الإيميل:</p>
                <a href='{confirmUrl}' 
                   style='background:#1565c0; color:white; padding:12px 24px; 
                          text-decoration:none; border-radius:6px; display:inline-block;'>
                    تأكيد الإيميل
                </a>
                <p style='margin-top: 20px;'>
                    بعد تأكيد الإيميل، سيتم مراجعة طلبكم من قِبل وزارة الصحة.
                </p>
                <p style='color:#888; font-size:13px;'>
                    إذا لم تقم بالتسجيل، تجاهل هذا الإيميل.
                </p>
            </div>"
        );

        return Ok(new
        {
            message = "تم التسجيل بنجاح. تحقق من إيميلك ثم انتظر موافقة الوزارة.",
            hospitalId = hospital.Id,
            userId = user.Id
        });
    }
}
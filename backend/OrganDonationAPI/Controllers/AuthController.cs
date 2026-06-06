using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using OrganDonationAPI.Data;
using OrganDonationAPI.DTOs;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using System.Text;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IConfiguration _config;
    private readonly AppDbContext _context;

    public AuthController(
        UserManager<ApplicationUser> userManager,
        IConfiguration config,
        AppDbContext context)
    {
        _userManager = userManager;
        _config = config;
        _context = context;
    }

    // ─────────────────────────────────────────
    // POST: api/auth/login
    // ─────────────────────────────────────────
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
            return Unauthorized(new { message = "Invalid credentials" });

        //  تحقق من تأكيد الإيميل
        if (!await _userManager.IsEmailConfirmedAsync(user))
            return Unauthorized(new { message = "يرجى تأكيد إيميلك أولاً قبل تسجيل الدخول." });

        // تحقق موافقة الوزارة للمستشفيات
        if (user.Role == "HospitalAdmin")
        {
            var hospital = await _context.Hospitals
                .FirstOrDefaultAsync(h => h.UserId == user.Id);
            if (hospital == null || hospital.Status != "Approved")
                return Unauthorized(new { message = "حسابك قيد المراجعة، انتظر موافقة الوزارة." });
        }

        var roles = await _userManager.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? user.Role ?? "";
        var token = GenerateJwtToken(user, role);

        return Ok(new { token, role, name = user.FullName });
    }

    // ─────────────────────────────────────────
    // GET: api/auth/confirm-email?userId=xxx&token=yyy
    // ─────────────────────────────────────────
    [HttpGet("confirm-email")]
    public async Task<IActionResult> ConfirmEmail(string userId, string token)
    {
        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(token))
            return Content(ErrorHtml("بيانات غير صالحة"), "text/html");

        var user = await _userManager.FindByIdAsync(userId);
        if (user == null)
            return Content(ErrorHtml("المستخدم غير موجود"), "text/html");

        if (user.EmailConfirmed)
            return Content(SuccessHtml(user.FullName), "text/html");

        token = token.Replace(" ", "+");
        var result = await _userManager.ConfirmEmailAsync(user, token);

        if (!result.Succeeded)
            return Content(ErrorHtml("رابط غير صالح أو منتهي الصلاحية"), "text/html");

        return Content(SuccessHtml(user.FullName), "text/html");
    }

    private string SuccessHtml(string name) => $@"
<!DOCTYPE html>
<html dir='rtl' lang='ar'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>تأكيد الإيميل</title>
<link rel=""stylesheet"" href=""https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css"">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ font-family: 'Segoe UI', Arial, sans-serif; background: #fff5f5; display: flex; align-items: center; justify-content: center; min-height: 100vh; }}
  .card {{ background: white; border-radius: 20px; padding: 48px 40px; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 4px 24px rgba(229,57,53,0.10); }}
  .logo {{ color: #c62828; font-size: 14px; font-weight: 600; margin-bottom: 28px; letter-spacing: 0.5px; }}
  .icon {{ width: 88px; height: 88px; background: #ffebee; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; }}
  .icon i {{ font-size: 40px; color: #e53935; }}
  h1 {{ color: #e53935; font-size: 22px; font-weight: 500; margin-bottom: 12px; }}
  p {{ color: #666; font-size: 15px; line-height: 1.8; margin-bottom: 6px; }}
  .name {{ color: #333; font-weight: 500; }}
  .btn {{ display: inline-block; margin-top: 28px; background: #e53935; color: white; padding: 14px 36px; border-radius: 10px; text-decoration: none; font-size: 15px; font-weight: 500; }}
  .note {{ color: #aaa; font-size: 13px; margin-top: 24px; line-height: 1.7; }}
</style>
</head>
<body>
<div class='card'>
  <div class='logo'>&#10084;&#65039; منصة الأمل للتبرع بالأعضاء</div>
<div class='icon'><i class='ti ti-circle-check'></i></div>
  <h1>تم تأكيد الإيميل بنجاح!</h1>
  <p>مرحباً <span class='name'>{name}</span></p>
  <p>حسابك مفعّل الآن، يمكنك تسجيل الدخول من التطبيق.</p>
<a class='btn' href='#' onclick='window.close(); return false;'>إغلاق والعودة للتطبيق</a>

<script>
  setTimeout(() => {{ window.close(); }}, 4000);
</script>
</div>
</body>
</html>";

    private string ErrorHtml(string msg) => $@"
<!DOCTYPE html>
<html dir='rtl' lang='ar'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>خطأ</title>
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{ font-family: 'Segoe UI', Arial, sans-serif; background: #fff5f5; display: flex; align-items: center; justify-content: center; min-height: 100vh; }}
  .card {{ background: white; border-radius: 20px; padding: 50px 40px; max-width: 420px; width: 90%; text-align: center; box-shadow: 0 4px 24px rgba(229,57,53,0.10); }}
  .icon {{ width: 90px; height: 90px; background: #fff0f0; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 24px; font-size: 44px; }}
  .logo {{ color: #e53935; font-size: 15px; font-weight: bold; margin-bottom: 28px; }}
  h1 {{ color: #e53935; font-size: 22px; margin-bottom: 12px; }}
  p {{ color: #666; font-size: 15px; line-height: 1.7; }}
</style>
</head>
<body>
<div class='card'>
  <div class='logo'>❤️ منصة الأمل للتبرع بالأعضاء</div>
  <div class='icon'>❌</div>
  <h1>حدث خطأ</h1>
  <p>{msg}</p>
</div>
</body>
</html>";

    // ─────────────────────────────────────────
    // Private: Generate JWT
    // ─────────────────────────────────────────
    private string GenerateJwtToken(ApplicationUser user, string role)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Email, user.Email!),
            new Claim(ClaimTypes.Role, role)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
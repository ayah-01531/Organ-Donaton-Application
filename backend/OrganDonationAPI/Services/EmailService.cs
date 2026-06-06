using System.Net;
using System.Net.Mail;

namespace OrganDonationAPI.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;
        public EmailService(IConfiguration config) => _config = config;

        public async Task SendAsync(string to, string subject, string body)
        {
            var smtp = new SmtpClient(_config["Email:Host"])
            {
                Port = int.Parse(_config["Email:Port"]),
                Credentials = new NetworkCredential(
                    _config["Email:Username"],
                    _config["Email:Password"]),
                EnableSsl = true
            };
            var mail = new MailMessage(_config["Email:From"], to, subject, body)
            {
                IsBodyHtml = true
            };
            await smtp.SendMailAsync(mail);
        }

        public string ConfirmationEmailBody(string name, string confirmUrl) => $@"
<!DOCTYPE html>
<html dir='rtl' lang='ar'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
</head>
<body style='margin:0;padding:0;background:#f4f4f4;font-family:Segoe UI,Arial,sans-serif;'>
<table width='100%' cellpadding='0' cellspacing='0'>
  <tr>
    <td align='center' style='padding:32px 16px;'>
      <table width='560' cellpadding='0' cellspacing='0' style='max-width:560px;width:100%;'>
        <tr>
          <td style='background:#e53935;border-radius:12px 12px 0 0;padding:28px 32px;text-align:center;'>
            <p style='margin:0;color:white;font-size:13px;letter-spacing:1px;'>
              &#10084;&#65039; منصة الأمل للتبرع بالأعضاء
            </p>
          </td>
        </tr>
        <tr>
          <td style='background:white;padding:40px 36px;text-align:center;border-left:1px solid #eee;border-right:1px solid #eee;'>
            <h1 style='margin:0 0 8px;color:#1a1a1a;font-size:20px;font-weight:600;'>تأكيد البريد الإلكتروني</h1>
            <p style='margin:0 0 24px;color:#999;font-size:13px;'>يرجى تأكيد بريدك الإلكتروني لتفعيل حسابك</p>
            <hr style='border:none;border-top:1px solid #f0f0f0;margin:0 0 28px;'>
            <p style='margin:0 0 6px;color:#444;font-size:15px;line-height:1.8;'>
              مرحباً <strong style='color:#1a1a1a;'>{name}</strong> &#128075;
            </p>
            <p style='margin:0 0 28px;color:#666;font-size:14px;line-height:1.8;'>
              شكراً لتسجيلك في نظام التبرع بالأعضاء.<br>
              اضغط على الزر أدناه لتأكيد حسابك:
            </p>
            <a href='{confirmUrl}'
               style='display:inline-block;background:#e53935;color:white;padding:13px 40px;border-radius:8px;text-decoration:none;font-size:15px;font-weight:500;'>
              تأكيد الإيميل
            </a>
            <p style='margin:28px 0 0;color:#bbb;font-size:12px;line-height:1.8;'>
              إذا لم تقم بالتسجيل، تجاهل هذا الإيميل.<br>
            </p>
          </td>
        </tr>
        <tr>
          <td style='background:#fafafa;border:1px solid #eee;border-top:none;border-radius:0 0 12px 12px;padding:20px 32px;text-align:center;'>
            <p style='margin:0;color:#bbb;font-size:12px;line-height:1.8;'>
              &copy; 2025 منصة الأمل للتبرع بالأعضاء<br>
              
            </p>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</body>
</html>";
    }
}
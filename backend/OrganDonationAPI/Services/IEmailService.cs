namespace OrganDonationAPI.Services
{
    public interface IEmailService
    {
        Task SendAsync(string to, string subject, string body);
        string ConfirmationEmailBody(string name, string confirmUrl); // أضف هذا
    }
}

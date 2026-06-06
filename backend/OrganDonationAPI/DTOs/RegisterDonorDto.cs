namespace OrganDonationAPI.DTOs
{
   public class RegisterDonorDto
{
    public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class LoginDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class DeceasedDto
    {
        public string NationalId { get; set; } = string.Empty;
        public string DeathCertificatePath { get; set; } = string.Empty;
        public DateTime DeathDate { get; set; }
    }
}

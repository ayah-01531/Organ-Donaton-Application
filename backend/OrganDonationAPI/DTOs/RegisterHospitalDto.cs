namespace OrganDonationAPI.DTOs
{
    public class RegisterHospitalDto
    {
        public string HospitalName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string LicenseNumber { get; set; } = string.Empty;
    }
    public class LoginHospitalDto
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }

    public class HospitalResponseDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public bool IsApprovedByMinistry { get; set; }
    }
}
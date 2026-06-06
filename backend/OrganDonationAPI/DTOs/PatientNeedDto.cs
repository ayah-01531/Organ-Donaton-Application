namespace OrganDonationAPI.DTOs
{
    public class PatientNeedDto
    {
        public string PatientName { get; set; } = string.Empty;
        public string NationalId { get; set; } = string.Empty;
        public string NeededOrgan { get; set; } = string.Empty;
        public string BloodType { get; set; } = string.Empty;
    }
}

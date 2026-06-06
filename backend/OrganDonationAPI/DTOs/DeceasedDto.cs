namespace OrganDonationAPI.DTOs
{
    public class DeceasedDtos
    {
        public string NationalId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public DateTime DateOfDeath { get; set; }
        public bool WasRegisteredDonor { get; set; }
        public string AvailableOrgans { get; set; } = string.Empty;
    }
}

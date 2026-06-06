namespace OrganDonationAPI.Models
{
    public class DeceasedPatient
    {
        public int Id { get; set; }
        public string NationalId { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public DateTime DateOfDeath { get; set; }
        public bool WasRegisteredDonor { get; set; } = false;
        public string AvailableOrgans { get; set; } = string.Empty;

        // Foreign Key
        public int HospitalId { get; set; }
        public Hospital Hospital { get; set; } = null!;
    }
}

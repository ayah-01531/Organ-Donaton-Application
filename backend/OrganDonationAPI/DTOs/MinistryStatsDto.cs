namespace OrganDonationAPI.DTOs
{
    // DTO للإحصائيات
    public class MinistryStatsDto
    {
        public HospitalStats Hospitals { get; set; }
        public DonorStats Donors { get; set; }

        public class HospitalStats
        {
            public int Total { get; set; }
            public int Approved { get; set; }
            public int Pending { get; set; }
            public int Rejected { get; set; }
        }

        public class DonorStats
        {
            public int Total { get; set; }
            public int Approved { get; set; }
            public int Pending { get; set; }
            public int Rejected { get; set; }
        }
    }
}

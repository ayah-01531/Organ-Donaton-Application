using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using OrganDonationAPI.Data;
using OrganDonationAPI.DTOs;
using OrganDonationAPI.Models;
using Microsoft.AspNetCore.Mvc;

namespace OrganDonationAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PatientNeedsController : ControllerBase
    {
        private readonly AppDbContext _context;
        public PatientNeedsController(AppDbContext context) => _context = context;

        // GET: api/patientneeds
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var hospitalId = int.Parse(User.FindFirst("hospitalId")!.Value);
            var needs = await _context.PatientNeeds
                .Where(p => p.Id == hospitalId)
                .ToListAsync();
            return Ok(needs);
        }

        // POST: api/patientneeds
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] PatientNeedDto dto)
        {
            var hospitalId = int.Parse(User.FindFirst("hospitalId")!.Value);

            var patient = new PatientNeed
            {
                PatientName = dto.PatientName,
                NationalId = dto.NationalId,
                NeededOrgan = dto.NeededOrgan,
                BloodType = dto.BloodType,
                Status = "Waiting",
                Id = hospitalId
            };

            _context.PatientNeeds.Add(patient);
            await _context.SaveChangesAsync();
            return Ok(patient);
        }
    }
}

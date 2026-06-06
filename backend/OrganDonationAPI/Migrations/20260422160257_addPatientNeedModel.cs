using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrganDonationAPI.Migrations
{
    /// <inheritdoc />
    public partial class addPatientNeedModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "HospitalName",
                table: "Hospitals",
                newName: "Name");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Hospitals",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsApprovedByMinistry",
                table: "Hospitals",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.CreateTable(
                name: "PatientNeed",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PatientName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NationalId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NeededOrgan = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    BloodType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RegisteredAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    HospitalId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PatientNeed", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PatientNeed_Hospitals_HospitalId",
                        column: x => x.HospitalId,
                        principalTable: "Hospitals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PatientNeed_HospitalId",
                table: "PatientNeed",
                column: "HospitalId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PatientNeed");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Hospitals");

            migrationBuilder.DropColumn(
                name: "IsApprovedByMinistry",
                table: "Hospitals");

            migrationBuilder.RenameColumn(
                name: "Name",
                table: "Hospitals",
                newName: "HospitalName");
        }
    }
}

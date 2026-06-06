using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace OrganDonationAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddRelationships : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Donors_AspNetUsers_UserId",
                table: "Donors");

            migrationBuilder.DropForeignKey(
                name: "FK_PatientNeed_Hospitals_HospitalId",
                table: "PatientNeed");

            migrationBuilder.DropTable(
                name: "Deceased");

            migrationBuilder.DropIndex(
                name: "IX_Hospitals_UserId",
                table: "Hospitals");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PatientNeed",
                table: "PatientNeed");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Donors",
                table: "Donors");

            migrationBuilder.DropIndex(
                name: "IX_Donors_UserId",
                table: "Donors");

            migrationBuilder.RenameTable(
                name: "PatientNeed",
                newName: "PatientNeeds");

            migrationBuilder.RenameTable(
                name: "Donors",
                newName: "Donor");

            migrationBuilder.RenameIndex(
                name: "IX_PatientNeed_HospitalId",
                table: "PatientNeeds",
                newName: "IX_PatientNeeds_HospitalId");

            migrationBuilder.AlterColumn<string>(
                name: "LicenseNumber",
                table: "Hospitals",
                type: "nvarchar(450)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Hospitals",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "LicenseNumber",
                table: "AspNetUsers",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "NationalId",
                table: "Donor",
                type: "nvarchar(450)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PatientNeeds",
                table: "PatientNeeds",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Donor",
                table: "Donor",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "DeceasedPatients",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NationalId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DateOfDeath = table.Column<DateTime>(type: "datetime2", nullable: false),
                    WasRegisteredDonor = table.Column<bool>(type: "bit", nullable: false),
                    AvailableOrgans = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    HospitalId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DeceasedPatients", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DeceasedPatients_Hospitals_HospitalId",
                        column: x => x.HospitalId,
                        principalTable: "Hospitals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Hospitals_LicenseNumber",
                table: "Hospitals",
                column: "LicenseNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Hospitals_UserId",
                table: "Hospitals",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Donor_NationalId",
                table: "Donor",
                column: "NationalId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Donor_UserId",
                table: "Donor",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DeceasedPatients_HospitalId",
                table: "DeceasedPatients",
                column: "HospitalId");

            migrationBuilder.AddForeignKey(
                name: "FK_Donor_AspNetUsers_UserId",
                table: "Donor",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PatientNeeds_Hospitals_HospitalId",
                table: "PatientNeeds",
                column: "HospitalId",
                principalTable: "Hospitals",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Donor_AspNetUsers_UserId",
                table: "Donor");

            migrationBuilder.DropForeignKey(
                name: "FK_PatientNeeds_Hospitals_HospitalId",
                table: "PatientNeeds");

            migrationBuilder.DropTable(
                name: "DeceasedPatients");

            migrationBuilder.DropIndex(
                name: "IX_Hospitals_LicenseNumber",
                table: "Hospitals");

            migrationBuilder.DropIndex(
                name: "IX_Hospitals_UserId",
                table: "Hospitals");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PatientNeeds",
                table: "PatientNeeds");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Donor",
                table: "Donor");

            migrationBuilder.DropIndex(
                name: "IX_Donor_NationalId",
                table: "Donor");

            migrationBuilder.DropIndex(
                name: "IX_Donor_UserId",
                table: "Donor");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "Hospitals");

            migrationBuilder.DropColumn(
                name: "LicenseNumber",
                table: "AspNetUsers");

            migrationBuilder.RenameTable(
                name: "PatientNeeds",
                newName: "PatientNeed");

            migrationBuilder.RenameTable(
                name: "Donor",
                newName: "Donors");

            migrationBuilder.RenameIndex(
                name: "IX_PatientNeeds_HospitalId",
                table: "PatientNeed",
                newName: "IX_PatientNeed_HospitalId");

            migrationBuilder.AlterColumn<string>(
                name: "LicenseNumber",
                table: "Hospitals",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");

            migrationBuilder.AlterColumn<string>(
                name: "NationalId",
                table: "Donors",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");

            migrationBuilder.AddPrimaryKey(
                name: "PK_PatientNeed",
                table: "PatientNeed",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Donors",
                table: "Donors",
                column: "Id");

            migrationBuilder.CreateTable(
                name: "Deceased",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HospitalId = table.Column<int>(type: "int", nullable: false),
                    DeathCertificatePath = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DeathDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDonor = table.Column<bool>(type: "bit", nullable: false),
                    NationalId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Deceased", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Deceased_Hospitals_HospitalId",
                        column: x => x.HospitalId,
                        principalTable: "Hospitals",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Hospitals_UserId",
                table: "Hospitals",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Donors_UserId",
                table: "Donors",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Deceased_HospitalId",
                table: "Deceased",
                column: "HospitalId");

            migrationBuilder.AddForeignKey(
                name: "FK_Donors_AspNetUsers_UserId",
                table: "Donors",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_PatientNeed_Hospitals_HospitalId",
                table: "PatientNeed",
                column: "HospitalId",
                principalTable: "Hospitals",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}

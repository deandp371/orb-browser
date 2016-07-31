/*
 * MPOrbit.js
 *
 * object and supporting functions for a Minor Planet Orbit in the MPC format
 */
function MPOrbit(line) {
	//console.log(line);
	this.line = line;
	this.designationPacked =line.slice(0,7).trim(); // designation in packed form text
	this.H = Number(line.slice(8,13));              // absolute magnitude, H numeric
	this.G = Number(line.slice(14,19));             // slope parameter, G numeric
	this.epochPacked = line.slice(20,25).trim();    // epoch packed - text
	
	this.M = Number(line.slice(26,35));             // mean anomoly numeric
	this.peri = Number(line.slice(37,46));          // Argument of perihelion, numeric
	this.node = Number(line.slice(48,57));          // Longitude of the ascending node, numeric
	this.i = Number(line.slice(59,68));   // Inclination to the ecliptic, numeric
	
	this.e = Number(line.slice(70,79));   // Orbital eccentricity, numeric
	this.n = Number(line.slice(80,91));   // mean daily motion, numeric
	this.a = Number(line.slice(92,103));   // semimajor axis, numeric
	
	this.U = line.slice(105,106);   // uncertainty parameter - text

	this.reference = line.slice(107,116);   // reference - text
	
	this.nObservations = Number(line.slice(117,122));   // Number of observations, numeric
	this.nOppositions = Number(line.slice(123,126));   // Number of oppositions, numeric
	
	this.obsInfo = line.slice(127,136);   // first and last obs or number of days
	
	this.residual = Number(line.slice(137,141));   // residual RMS, numeric

	this.perturbCoarse = line.slice(142,145);   // Coarse indicator of perturbers - text
	this.perturbPrecise = line.slice(146,149);   // Precise indicator of perturbers - text

	this.flags = line.slice(161,165);   // Precise indicator of perturbers - text
	this.orbitType = getOrbitType(this.flags);
	this.neoFlag = isNEO(this.flags);
	this.km1Flag = is1KM(this.flags);
	this.opp1Flag = is1Opp(this.flags);
	this.critFlag = isCrit(this.flags);
	this.phaFlag = isPHA(this.flags);
	
	this.designation = line.slice(166,194);   // Readable designation - text
	this.orbitDate = line.slice(194,202);   // Date last obs incl in orbit solution - text
	
	this.toTSV = function() {
		return this.designationPacked + "\t"
			+ this.H + "\t"
			+ this.G + "\t"
			+ this.epochPacked + "\t"
			+ this.a + "\t"
			+ this.e + "\t"
			+ this.i + "\t"
			+ this.node + "\t"
			+ this.peri + "\t"
			+ this.M + "\t"
			+ this.n + "\t"
			+ this.U + "\t"
			+ this.reference + "\t"
			+ this.nObservations + "\t"
			+ this.nOppositions + "\t"
			+ this.obsInfo + "\t"
			+ this.residual + "\t"
			+ this.perturbCoarse + "\t"
			+ this.perturbPrecise + "\t"
			+ this.flags + "\t"
			+ this.orbitType + "\t"
			+ this.neoFlag + "\t"
			+ this.km1Flag + "\t"
			+ this.opp1Flag + "\t"
			+ this.critFlag + "\t"
			+ this.phaFlag + "\t"
			+ this.designation + "\t"
			+ this.orbitDate;
	}
}

// return the orbit type from the hex flags value lower 5 bits

function getOrbitType(flags) {
  var typeVal = parseInt(flags,16) & 0x1F;
  var typeNames = [
	"Unassigned",
	"Atir",
        "Aten",
        "Apollo",
        "Amor",
        "Object with q < 1.665 AU",
        "Hungaria",
        "Phocaea",
        "Hilda",
        "Jupiter Trojan",
        "Distant object"
	];
  var returnType = (typeVal <= 10) ? typeNames[typeVal] : "";
  return returnType;
}

// return the NEO flag from the hex flags bit 11

function isNEO(flags) {
  var typeVal = parseInt(flags,16) & 0x0800;
  var returnType = (typeVal > 0) ? 1 : 0;
  return returnType;
}

// return the 1km flag from the hex flags bit 12

function is1KM(flags) {
  var typeVal = parseInt(flags,16) & 0x1000;
  var returnType = (typeVal > 0) ? 1 : 0;
  return returnType;
}

// return the 1 opposition flag from the hex flags bit 13

function is1Opp(flags) {
  var typeVal = parseInt(flags,16) & 0x2000;
  var returnType = (typeVal > 0) ? 1 : 0;
  return returnType;
}

// return the critical list flag from the hex flags bit 14

function isCrit(flags) {
  var typeVal = parseInt(flags,16) & 0x4000;
  var returnType = (typeVal > 0) ? 1 : 0;
return returnType;
}

// return the PHA flag from the hex flags bit 15

function isPHA(flags) {
  var typeVal = parseInt(flags,16) & 0x8000;
  var returnType = (typeVal > 0) ? 1 : 0;
  return returnType;
}
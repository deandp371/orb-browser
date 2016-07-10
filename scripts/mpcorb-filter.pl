use strict;
use warnings;
use Text::FixedWidth;


my $filename = 'NEA.txt';
#my $filename = 'Soft00CritList.txt';

open(my $inputFh, "<", $filename) or die "could not open file $filename";

my $mpcOutputFileName = "mpc-out.txt";
open(my $mpcOutputFh, ">", $mpcOutputFileName) or die "could not open output file $mpcOutputFileName";

my $readableOutFileName = "readable-out.txt";
open(my $readableOutputFh, ">", $readableOutFileName) or die "could not open output file $readableOutFileName";

my $filterTypeValue = undef;
my $filterIsCrit = undef;
my $filterUMin = 1;
my $filterUMax = 4;
my $filterDateLastObsMax = "20160401";

my $inputCount = 0;
my $outputCount = 0;

my $packedDesig = '';
my $H = '';		# absolute mag
my $G = '';		# slope
my $epoch = '';		# epoch packed
my $M = '';		# mean anomoly at epoch
my $peri = '';		# arg of perihelion
my $node = '';		# long of ascending node
my $incl = '';		# inclination
my $e = '';		# eccentricity
my $motion = '';	# mean daily motion
my $a = '';		# semimajor axis
my $U = '';		# uncertainty value or flag
my $ref = '';		# reference
my $nobs = '';		# number of observations
my $nopp = '';		# number of oppositions
my $yFirstObs = '';	# year first observed
my $yLastObs = '';	# year last observed
my $arcLength = '';	# arc length
my $rmsResid = '';	# rms id
my $coarsePerturb = '';		# coarse perturbers
my $precisePerturb = '';	# precise perturbers
my $computerName = '';	# computer name
my $flags = '';		# type flags
my $desig = '';		# full designation
my $dateLastObs = '';	# date last obs
my $typeVal = '';	# type value from flags

# names for the type value
my %typeNames = (
	1 , 'Atira',
        2 , 'Aten',
        3 , 'Apollo',
        4 , 'Amor',
        5 , 'Object with q < 1.665 AU',
        6 , 'Hungaria',
        7 , 'Phocaea',
        8 , 'Hilda',
        9 , 'Jupiter Trojan',
       10 , 'Distant object'
);

my $rest;

my $fwParser = new Text::FixedWidth;
$fwParser->set_attributes(qw(
	packedDesig	undef	%7s
	space01		undef	%1s
	H		undef	%5.2f
	space02		undef	%1s
	G		undef	%5.2f
	space03		undef	%1s
	epoch		undef   %5s
	space04         undef   %1s
	M		undef   %9.5f
	space05		undef	%2s
	peri		undef	%9.5f
	space06		undef	%2s
	node		undef	%9.5f
	space07		undef	%2s
	incl		undef	%9.5f
	space08		undef	%2s
	e		undef	%9.7f
	space09		undef	#1s
	motion		undef	%11.8f
	space10		undef	%1s
	a		undef	%11.7f
	space11		undef	%2s
	U		undef	%1d
	space12		undef	%1s
	ref		undef	%9s
	space13		undef	%1s
	nobs		undef	%5d
	space14		undef	%1s
	nopp		undef	%3d
	space15		undef	%1s
	yFirstObs	undef	%4d
	space16		undef	%1s
	yLastObs	undef	%4d
	space17		undef	%1s
	rmsResid	undef	f4.2
	space18		undef	%1s
	coarsePerturb	undef	%3s
	space19		undef	%1s
	precisePerturb	undef	%3s
	space20		undef	%1s
	computerName	undef	%10s
	space21		undef	%1s
	flags		undef	%4s
	space22		undef	%1s
	desig		undef	%28s
	dateLastObs	undef	%8d
));

print $readableOutputFh "Packed\tH\tG\tEpoch\tM\tPeri\tNode\tIncl\te\tmotion\t"
	. "a\tU\tRef\tnobs\tnopp\tFirstObs=\tyLastObs\tarcLength\t"
	. "RMSResid\tCoarsPert\tPrecPert\tComputer\tflags\t"
	. "typeVal\ttypeName\tisNeo\tis1-KM+\tisCrit\tisPha\tdesig\tdateLastObs\n";

while(my $row = <$inputFh>) {
	++$inputCount;
			
	$fwParser->parse(string => $row);
	$packedDesig = $fwParser->get_packedDesig;
	$H = $fwParser->get_H;
	$G = $fwParser->get_G;
	$epoch = $fwParser->get_epoch;
	$M = $fwParser->get_M;
	$peri = $fwParser->get_peri;
	$node = $fwParser->get_node;
	$incl = $fwParser->get_incl;
	$e = $fwParser->get_e;
	$motion = $fwParser->get_motion;
	$a = $fwParser->get_a;
	$U = $fwParser->get_U;
	$ref = $fwParser->get_ref;
	$nobs = $fwParser->get_nobs;
	$nopp = $fwParser->get_nopp;
	$yFirstObs = $fwParser->get_yFirstObs;
	$yLastObs = $fwParser->get_yLastObs;
	if($nopp == 1) {
		$arcLength = $yFirstObs;
		$yFirstObs = undef;
		$yLastObs = undef;
	}
	$rmsResid = $fwParser->get_rmsResid;
	$coarsePerturb = $fwParser->get_coarsePerturb;
	$precisePerturb = $fwParser->get_precisePerturb;
	$computerName = $fwParser->get_computerName;
	$flags = $fwParser->get_flags;
	# get the lowest byte out of flags
	#my $lowByte = hex(substr($flags, 3, 1));
	# orbit type in the lowest 5 bits
	$typeVal = hex($flags) & 0x1F;
	my $typeName = (exists $typeNames{$typeVal}) ? $typeNames{$typeVal} : "Unknown";
	
	my $neoVal  = hex($flags) & 0x0800;
	my $km1Val  = hex($flags) & 0x1000;
	my $critVal = hex($flags) & 0x4000;
	my $phaVal  = hex($flags) & 0x8000;
	
	my $isNeo  = ($neoVal > 0) ? "T" : "F";		# bit 11
	my $is1Km  = ($km1Val > 0) ? "T" : "F";				# bit 12
	my $isCrit = ($critVal > 0) ? "T" : "F";		# bit 14
	my $isPha  = ($phaVal > 0) ? "T" : "F";		# bit 15
	
	$desig = $fwParser->get_desig;
	$dateLastObs = $fwParser->get_dateLastObs;
	
	if( defined $filterTypeValue ) {
		next unless($typeVal == $filterTypeValue);
	}
	if( defined $filterIsCrit ) {
		next unless($isCrit eq "T");
	}
	if( defined $filterUMax ) {
		next unless($U <= $filterUMax);
	}
	if( defined $filterUMin ) {
		next unless($U >= $filterUMin);
	}
	if( defined $filterDateLastObsMax ) {
		next unless($dateLastObs <= $filterDateLastObsMax);
	}

	++$outputCount;
	print $mpcOutputFh $row;
	print $readableOutputFh "$packedDesig\t$H\t$G \t$epoch\t$M\t$peri\t$node\t$incl\t$e\t$motion\t"
	. "$a\t$U\t$ref\t$nobs\t$nopp\t$yFirstObs\t$yLastObs\t$arcLength\t"
	. "$rmsResid\t$coarsePerturb\t$precisePerturb\t$computerName\t$flags\t"
	. "$typeVal\t$typeName\t$isNeo\t$is1Km\t$isCrit\t$isPha\t$desig\t$dateLastObs\n";
}
print "input count= $inputCount output count = $outputCount\n";
close($inputFh);
close($mpcOutputFh);
close($readableOutputFh);

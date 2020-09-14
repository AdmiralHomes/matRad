function stf = matRad_generateStfPencilBeam(pln,EnergyIx)

load([pln.radiationMode,'_',pln.machine]);

SAD = machine.meta.SAD;
currentMinimumFWHM = matRad_interp1(machine.meta.LUT_bxWidthminFWHM(1,:)', machine.meta.LUT_bxWidthminFWHM(2,:)',pln.propStf.bixelWidth);

%% generate stf parameters
stf.gantryAngle = pln.propStf.gantryAngles;
stf.couchAngle = pln.propStf.couchAngles;
stf.bixelWidth = pln.propStf.bixelWidth;
stf.radiationMode = pln.radiationMode;
stf.SAD = SAD;
stf.isoCenter = pln.propStf.isoCenter;

stf.numOfRays = 1;
stf.numOfBixelsPerRay = 1;
stf.totalNumOfBixels = 1;

stf.soucePoint_bev = [0,-SAD,0];
stf.soucePoint = [0,-SAD,0];

%% generate ray
stf.ray.energy = machine.data(EnergyIx).energy;
stf.ray.focusIx = find(machine.data(EnergyIx).initFocus.SisFWHMAtIso > currentMinimumFWHM,1,'first');
stf.ray.rangeShifter = struct;
stf.ray.rangeShifter.ID = 0;
stf.ray.rangeShifter.eqThickness = 0;
stf.ray.rangeShifter.sourceRashiDistance = 0;

stf.ray.rayPos_bev = [0,0,0];
stf.ray.targetPoint_bev = [0,SAD,0];
stf.ray.rayPos = [0,0,0];
stf.ray.targetPoint = [0,SAD,0];

end
const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;

fn mEnum(comptime c_name: []const u8, comptime prefix: []const u8) type {
    comptime var field_names: [1024][]const u8 = undefined;
    comptime var field_values: [1024]u32 = undefined;
    comptime var count = 0;

    @setEvalBranchQuota(100000);
    inline for (std.meta.declarations(ffi)) |decl| {
        if (decl.name.len <= prefix.len) {
            continue;
        }

        if (std.mem.eql(u8, decl.name[0..prefix.len], prefix)) {
            const lowered_name = toLowerCase(decl.name[prefix.len..]);

            field_names[count] = lowered_name;
            field_values[count] = @field(ffi, decl.name);

            count += 1;
        }
    }

    if (count <= 0) {
        @compileError("No values found with prefix: " ++ prefix);
    }

    return @Enum(
        @field(ffi, c_name),
        .exhaustive,
        field_names[0..count],
        field_values[0..count],
    );
}

fn toLowerCase(comptime input: []const u8) []const u8 {
    var output: [input.len]u8 = undefined;
    for (input, 0..) |c, i| {
        output[i] = if (c >= 'A' and c <= 'Z') c + 32 else c;
    }

    return output[0..];
}

// Enumerations ordered by MuJoCo documentation. https://mujoco.readthedocs.io/en/stable/APIreference/APItypes.html
pub const enums = struct {
    pub const DisableFlag = mEnum("mjtDisableBit", "mjDSBL_");
    pub const NDisableFlag = ffi.mjNDISABLE;

    pub const EnableFlag = mEnum("mjtEnableBit", "mjENBL_");
    pub const NEnableFlag = ffi.mjNENABLE;

    pub const PrimitiveJointType = mEnum("mjtJoint", "mjJNT_");

    pub const GeomType = mEnum("mjtGeom", "mjGEOM_");
    pub const NGeomTypes = ffi.mjNGEOMTYPES;

    pub const CameraProjection = mEnum("mjtProjection", "mjPROJ_");
    pub const CamLightMode = mEnum("mjtCamLight", "mjCAMLIGHT_");
    pub const LightType = mEnum("mjtLightType", "mjLIGHT_");
    pub const TextureType = mEnum("mjtTexture", "mjTEXTURE_");
    pub const TextureRole = mEnum("mjtTextureRole", "mjTEXTUREROLE_");
    pub const ColorSpaceEncoding = mEnum("mjtColorSpace", "mjCOLORSPACE_");
    pub const IntegratorType = mEnum("mjtIntegrator", "mjINT_");
    pub const FrictionConeType = mEnum("mjtCone", "mjCONE_");
    pub const JacobianType = mEnum("mjtJacobian", "mjJAC_");
    pub const SolverAlgorithm = mEnum("mjtSolver", "mjSOL_");
    pub const EqConstraintType = mEnum("mjtEq", "mjEQ_");
    pub const TendonWrapType = mEnum("mjtWrap", "mjWRAP_");
    pub const ActuatorTransmissionType = mEnum("mjtTrn", "mjTRN_");
    pub const ActuatorDynamicsType = mEnum("mjtDyn", "mjDYN_");
    pub const ActuatorGainType = mEnum("mjtGain", "mjGAIN_");
    pub const ActuatorBiasType = mEnum("mjtBias", "mjBIAS_");

    pub const ObjectType = mEnum("mjtObj", "mjOBJ_");
    pub const NObjectTypes = ffi.mjNOBJECT;

    pub const SensorType = mEnum("mjtSensor", "mjSENS_");
    pub const ComputeStage = mEnum("mjtStage", "mjSTAGE_");
    pub const SensorDataType = mEnum("mjtDataType", "mjDATATYPE_");
    pub const ContactSensorDataField = mEnum("mjtConDataField", "mjCONDATA_");
    pub const RayDataField = mEnum("mjtRayDataField", "mjRAYDATA_");
    pub const CamOutFlag = mEnum("mjtCamOutBit", "mjCAMOUT_");
    pub const SameFrame = mEnum("mjtSameFrame", "mjSAMEFRAME_");
    pub const SleepPolicy = mEnum("mjtSleepPolicy", "mjSLEEP_");
    pub const LRMode = mEnum("mjtLRMode", "mjLRMODE_");
    pub const FlexSelf = mEnum("mjtFlexSelf", "mjFLEXSELF_");
    pub const SDFType = mEnum("mjtSDFType", "mjSDFTYPE_");

    pub const StateFlag = mEnum("mjtState", "mjSTATE_");
    pub const NStateFlags = ffi.mjNSTATE;

    pub const ConstraintType = mEnum("mjtConstraint", "mjCNSTR_");
    pub const ConstraintState = mEnum("mjtConstraintState", "mjCNSTRSTATE_");
    pub const WarningType = mEnum("mjtWarning", "mjWARN_");
    pub const TimerType = mEnum("mjtTimer", "mjTIMER_");
    pub const SleepState = mEnum("mjtSleepState", "mjS_");

    pub const CategoryFlag = mEnum("mjtCatBit", "mjCAT_");
    pub const MouseAction = mEnum("mjtMouse", "mjMOUSE_");
    pub const PertubationFlag = mEnum("mjtPertBit", "mjPERT_");
    pub const CameraType = mEnum("mjtCamera", "mjCAMERA_");
    pub const VisLabel = mEnum("mjtLabel", "mjLABEL_");
    pub const FrameType = mEnum("mjtFrame", "mjFRAME_");
    pub const VisFlag = mEnum("mjtVisFlag", "mjVIS_");
    pub const RenderFlag = mEnum("mjtRndFlag", "mjRND_");
    pub const StereoRenderMode = mEnum("mjtStereo", "mjSTEREO_");

    pub const GridPosition = mEnum("mjtGridPos", "mjGRID_");
    pub const FrameBufferMode = mEnum("mjtFramebuffer", "mjFB_");
    pub const DepthMap = mEnum("mjtDepthMap", "mjDEPTH_");
    pub const FontScale = mEnum("mjtFontScale", "mjFONTSCALE_");
    pub const FontType = mEnum("mjtFont", "mjFONT_");

    pub const MouseButton = mEnum("mjtButton", "mjBUTTON_");
    pub const UiEvent = mEnum("mjtEvent", "mjEVENT_");

    pub const UiItemType = mEnum("mjtItem", "mjITEM_");
    pub const NUiItemTypes = ffi.mjNITEM;

    pub const UiSectionState = mEnum("mjtSection", "mjSECT_");

    pub const GeomInertiaType = mEnum("mjtGeomInertia", "mjINERTIA_");
    pub const BuiltinTextureType = mEnum("mjtBuiltin", "mjBUILTIN_");
    pub const TextureMarkType = mEnum("mjtMark", "mjMARK_");
    pub const LimitedType = mEnum("mjtLimited", "mjLIMITED_");
    pub const AlignFreeJoints = mEnum("mjtAlignFree", "mjALIGNFREE_");
    pub const InertiaFromGeom = mEnum("mjtInertiaFromGeom", "mjINERTIAFROMGEOM_");
    pub const Orientation = mEnum("mjtOrientation", "mjORIENTATION_");
    pub const MeshInertiaType = mEnum("mjtMeshInertia", "mjMESH_INERTIA_");
    pub const BuiltinMeshType = mEnum("mjtMeshBuiltin", "mjMESH_BUILTIN_");

    pub const PluginCapabilityFlag = mEnum("mjtPluginCapabilityBit", "mjPLUGIN_");
};

test "enums" {
    const expectEqual = std.testing.expectEqual;

    _ = enums;

    try expectEqual(@intFromEnum(enums.PrimitiveJointType.ball), ffi.mjJNT_BALL);
    try expectEqual(enums.NObjectTypes, ffi.mjNOBJECT);

    try expectEqual(@intFromEnum(enums.ObjectType.unknown), ffi.mjOBJ_UNKNOWN);
    try expectEqual(@intFromEnum(enums.ObjectType.pair), ffi.mjOBJ_PAIR);

    try expectEqual(@intFromEnum(enums.DisableFlag.limit), ffi.mjDSBL_LIMIT);
}

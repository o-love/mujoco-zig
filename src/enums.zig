const std = @import("std");
const mujoco_zig = @import("root.zig");

const ffi = mujoco_zig.ffi;

fn mEnum(comptime prefix: []const u8) type {
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
        u32,
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
    pub const DisableFlag = mEnum("mjDSBL_");
    pub const NDisableFlag = ffi.mjNDISABLE;

    pub const EnableFlag = mEnum("mjENBL_");
    pub const NEnableFlag = ffi.mjNENABLE;

    pub const PrimitiveJointType = mEnum("mjJNT_");

    pub const GeomType = mEnum("mjGEOM_");
    pub const NGeomTypes = ffi.mjNGEOMTYPES;

    pub const CameraProjection = mEnum("mjPROJ_");
    pub const CamLightMode = mEnum("mjCAMLIGHT_");
    pub const LightType = mEnum("mjLIGHT_");
    pub const TextureType = mEnum("mjTEXTURE_");
    pub const TextureRole = mEnum("mjTEXTUREROLE_");
    pub const ColorSpaceEncoding = mEnum("mjCOLORSPACE_");
    pub const IntegratorType = mEnum("mjINT_");
    pub const FrictionConeType = mEnum("mjCONE_");
    pub const JacobianType = mEnum("mjJAC_");
    pub const SolverAlgorithm = mEnum("mjSOL_");
    pub const EqConstraintType = mEnum("mjEQ_");
    pub const TendonWrapType = mEnum("mjWRAP_");
    pub const ActuatorTransmissionType = mEnum("mjTRN_");
    pub const ActuatorDynamicsType = mEnum("mjDYN_");
    pub const ActuatorGainType = mEnum("mjGAIN_");
    pub const ActuatorBiasType = mEnum("mjBIAS_");

    pub const ObjectType = mEnum("mjOBJ_");
    pub const NObjectTypes = ffi.mjNOBJECT;

    pub const SensorType = mEnum("mjSENS_");
    pub const ComputeStage = mEnum("mjSTAGE_");
    pub const SensorDataType = mEnum("mjDATATYPE_");
    pub const ContactSensorDataField = mEnum("mjCONDATA_");
    pub const RayDataField = mEnum("mjRAYDATA_");
    pub const CamOutFlag = mEnum("mjCAMOUT_");
    pub const SameFrame = mEnum("mjSAMEFRAME_");
    pub const SleepPolicy = mEnum("mjSLEEP_");
    pub const LRMode = mEnum("mjLRMODE_");
    pub const FlexSelf = mEnum("mjFLEXSELF_");
    pub const SDFType = mEnum("mjSDFTYPE_");

    pub const StateFlag = mEnum("mjSTATE_");
    pub const NStateFlags = ffi.mjNSTATE;

    pub const ConstraintType = mEnum("mjCNSTR_");
    pub const ConstraintState = mEnum("mjCNSTRSTATE_");
    pub const WarningType = mEnum("mjWARN_");
    pub const TimerType = mEnum("mjTIMER_");
    pub const SleepState = mEnum("mjS_");

    pub const CategoryFlag = mEnum("mjCAT_");
    pub const MouseAction = mEnum("mjMOUSE_");
    pub const PertubationFlag = mEnum("mjPERT_");
    pub const CameraType = mEnum("mjCAMERA_");
    pub const VisLabel = mEnum("mjLABEL_");
    pub const FrameType = mEnum("mjFRAME_");
    pub const VisFlag = mEnum("mjVIS_");
    pub const RenderFlag = mEnum("mjRND_");
    pub const StereoRenderMode = mEnum("mjSTEREO_");

    pub const GridPosition = mEnum("mjGRID_");
    pub const FrameBufferMode = mEnum("mjFB_");
    pub const DepthMap = mEnum("mjDEPTH_");
    pub const FontScale = mEnum("mjFONTSCALE_");
    pub const FontType = mEnum("mjFONT_");

    pub const MouseButton = mEnum("mjBUTTON_");
    pub const UiEvent = mEnum("mjEVENT_");

    pub const UiItemType = mEnum("mjITEM_");
    pub const NUiItemTypes = ffi.mjNITEM;

    pub const UiSectionState = mEnum("mjSECT_");

    pub const GeomInertiaType = mEnum("mjINERTIA_");
    pub const BuiltinTextureType = mEnum("mjBUILTIN_");
    pub const TextureMarkType = mEnum("mjMARK_");
    pub const LimitedType = mEnum("mjLIMITED_");
    pub const AlignFreeJoints = mEnum("mjALIGNFREE_");
    pub const InertiaFromGeom = mEnum("mjINERTIAFROMGEOM_");
    pub const Orientation = mEnum("mjORIENTATION");
    pub const MeshInertiaType = mEnum("mjMESH_INERTIA_");
    pub const BuiltinMeshType = mEnum("mjMESH_BUILTIN_");

    pub const PluginCapabilityFlag = mEnum("mjPLUGIN_");
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

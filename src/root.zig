const std = @import("std");
pub const ffi = @import("c");
const build_options = @import("build_options");

pub const MjModel = @import("MjModel.zig");
pub const MjData = @import("MjData.zig");

// Visualization
pub const MjvCamera = @import("visualization/MjvCamera.zig");
pub const MjvOption = @import("visualization/MjvOption.zig");
pub const MjvScene = @import("visualization/MjvScene.zig");
pub const MjvPerturb = @import("visualization/MjvPerturb.zig");

// Opengl
pub const MjrContext = if (build_options.opengl) @import("visualization/opengl/MjrContext.zig") else @compileError("MjrContext requires the 'opengl' build option");

// Primitive Types
pub const MjtNum = ffi.mjtNum;
pub const MjtSize = ffi.mjtSize;
pub const MjtByte = ffi.mjtByte;

// Enums
pub const enums = @import("enums.zig").enums;

pub const MjtDisableBit = enums.DisableFlag;
pub const mjNDisable = enums.NDisableFlag;
pub const MjtEnableBit = enums.EnableFlag;
pub const mjNEnable = enums.NEnableFlag;
pub const MjtJoint = enums.PrimitiveJointType;
pub const MjtGeom = enums.GeomType;
pub const mjNGeomTypes = enums.NGeomTypes;
pub const MjtProjection = enums.CameraProjection;
pub const MjtCamLight = enums.CamLightMode;
pub const MjtLightType = enums.LightType;
pub const MjtTexture = enums.TextureType;
pub const MjtTextureRole = enums.TextureRole;
pub const MjtColorSpace = enums.ColorSpaceEncoding;
pub const MjtIntegrator = enums.IntegratorType;
pub const MjtCone = enums.FrictionConeType;
pub const MjtJacobian = enums.JacobianType;
pub const MjtSolver = enums.SolverAlgorithm;
pub const MjtEq = enums.EqConstraintType;
pub const MjtWrap = enums.TendonWrapType;
pub const MjtTrn = enums.ActuatorTransmissionType;
pub const MjtDyn = enums.ActuatorDynamicsType;
pub const MjtGain = enums.ActuatorGainType;
pub const MjtBias = enums.ActuatorBiasType;
pub const MjtObject = enums.ObjectType;
pub const mjNObject = enums.NObjectTypes;
pub const MjtSensor = enums.SensorType;
pub const MjtStage = enums.ComputeStage;
pub const MjtDataType = enums.SensorDataType;
pub const MjtConDataField = enums.ContactSensorDataField;
pub const MjtRayDataField = enums.RayDataField;
pub const MjtCamOutBit = enums.CamOutFlag;
pub const MjtSameFrame = enums.SameFrame;
pub const MjtSleepPolicy = enums.SleepPolicy;
pub const MjtLRMode = enums.LRMode;
pub const MjtFlexSelf = enums.FlexSelf;
pub const MjtSDFType = enums.SDFType;
pub const MjtState = enums.StateFlag;
pub const MjtConstraint = enums.ConstraintType;
pub const MjtConstraintState = enums.ConstraintState;
pub const MjtWarning = enums.WarningType;
pub const MjtTimer = enums.TimerType;
pub const MjtSleepState = enums.SleepState;
pub const MjtCatBit = enums.CategoryFlag;
pub const MjtMouse = enums.MouseAction;
pub const MjtPertBit = enums.PertubationFlag;
pub const MjtCamera = enums.CameraType;
pub const MjtLabel = enums.VisLabel;
pub const MjtFrame = enums.FrameType;
pub const MjtVisFlag = enums.VisFlag;
pub const MjtRndFlag = enums.RenderFlag;
pub const MjtStereo = enums.StereoRenderMode;
pub const MjtGridPos = enums.GridPosition;
pub const MjtFramebuffer = enums.FrameBufferMode;
pub const MjtDepthMap = enums.DepthMap;
pub const MjtFontScale = enums.FontScale;
pub const MjtFont = enums.FontType;
pub const MjtButton = enums.MouseButton;
pub const MjtEvent = enums.UiEvent;
pub const MjtItem = enums.UiItemType;
pub const mjNITEM = enums.NUiItemTypes;
pub const MjtSection = enums.UiSectionState;
pub const MjtGeomInertia = enums.GeomInertiaType;
pub const MjtBuiltin = enums.BuiltinTextureType;
pub const MjtMark = enums.TextureMarkType;
pub const MjtLimited = enums.LimitedType;
pub const MjtAlignFree = enums.AlignFreeJoints;
pub const MjtInertiaFromGeom = enums.InertiaFromGeom;
pub const MjtOrientation = enums.Orientation;
pub const MjtMeshInertia = enums.MeshInertiaType;
pub const MjtMeshBuiltin = enums.BuiltinMeshType;
pub const MjtPluginCapabilityBit = enums.PluginCapabilityFlag;

pub const init = @import("init.zig").init;

test {
    _ = @import("MjData.zig");
    _ = @import("MjModel.zig");
    _ = @import("log.zig");
    _ = @import("enums.zig");
    _ = @import("visualization/MjvCamera.zig");
    _ = @import("visualization/MjvOption.zig");
    _ = @import("visualization/MjvScene.zig");
    _ = @import("visualization/MjvPerturb.zig");

    if (build_options.opengl) {
        _ = @import("visualization/opengl/MjrContext.zig");
    }
}

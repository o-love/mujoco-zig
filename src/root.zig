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
pub const mjtNum = ffi.mjtNum;
pub const mjtSize = ffi.mjtSize;
pub const mjtByte = ffi.mjtByte;

// Enums
pub const enums = @import("enums.zig").enums;

pub const mjtDisableBit = enums.DisableFlag;
pub const mjNDisable = enums.NDisableFlag;
pub const mjtEnableBit = enums.EnableFlag;
pub const mjNEnable = enums.NEnableFlag;
pub const mjtJoint = enums.PrimitiveJointType;
pub const mjtGeom = enums.GeomType;
pub const mjNGeomTypes = enums.NGeomTypes;
pub const mjtProjection = enums.CameraProjection;
pub const mjtCamLight = enums.CamLightMode;
pub const mjtLightType = enums.LightType;
pub const mjtTexture = enums.TextureType;
pub const mjtTextureRole = enums.TextureRole;
pub const mjtColorSpace = enums.ColorSpaceEncoding;
pub const mjtIntegrator = enums.IntegratorType;
pub const mjtCone = enums.FrictionConeType;
pub const mjtJacobian = enums.JacobianType;
pub const mjtSolver = enums.SolverAlgorithm;
pub const mjtEq = enums.EqConstraintType;
pub const mjtWrap = enums.TendonWrapType;
pub const mjtTrn = enums.ActuatorTransmissionType;
pub const mjtDyn = enums.ActuatorDynamicsType;
pub const mjtGain = enums.ActuatorGainType;
pub const mjtBias = enums.ActuatorBiasType;
pub const mjtObject = enums.ObjectType;
pub const mjNObject = enums.NObjectTypes;
pub const mjtSensor = enums.SensorType;
pub const mjtStage = enums.ComputeStage;
pub const mjtDataType = enums.SensorDataType;
pub const mjtConDataField = enums.ContactSensorDataField;
pub const mjtRayDataField = enums.RayDataField;
pub const mjtCamOutBit = enums.CamOutFlag;
pub const mjtSameFrame = enums.SameFrame;
pub const mjtSleepPolicy = enums.SleepPolicy;
pub const mjtLRMode = enums.LRMode;
pub const mjtFlexSelf = enums.FlexSelf;
pub const mjtSDFType = enums.SDFType;
pub const mjtState = enums.StateFlag;
pub const mjtConstraint = enums.ConstraintType;
pub const mjtConstraintState = enums.ConstraintState;
pub const mjtWarning = enums.WarningType;
pub const mjtTimer = enums.TimerType;
pub const mjtSleepState = enums.SleepState;
pub const mjtCatBit = enums.CategoryFlag;
pub const mjtMouse = enums.MouseAction;
pub const mjtPertBit = enums.PertubationFlag;
pub const mjtCamera = enums.CameraType;
pub const mjtLabel = enums.VisLabel;
pub const mjtFrame = enums.FrameType;
pub const mjtVisFlag = enums.VisFlag;
pub const mjtRndFlag = enums.RenderFlag;
pub const mjtStereo = enums.StereoRenderMode;
pub const mjtGridPos = enums.GridPosition;
pub const mjtFramebuffer = enums.FrameBufferMode;
pub const mjtDepthMap = enums.DepthMap;
pub const mjtFontScale = enums.FontScale;
pub const mjtFont = enums.FontType;
pub const mjtButton = enums.MouseButton;
pub const mjtEvent = enums.UiEvent;
pub const mjtItem = enums.UiItemType;
pub const mjNITEM = enums.NUiItemTypes;
pub const mjtSection = enums.UiSectionState;
pub const mjtGeomInertia = enums.GeomInertiaType;
pub const mjtBuiltin = enums.BuiltinTextureType;
pub const mjtMark = enums.TextureMarkType;
pub const mjtLimited = enums.LimitedType;
pub const mjtAlignFree = enums.AlignFreeJoints;
pub const mjtInertiaFromGeom = enums.InertiaFromGeom;
pub const mjtOrientation = enums.Orientation;
pub const mjtMeshInertia = enums.MeshInertiaType;
pub const mjtMeshBuiltin = enums.BuiltinMeshType;
pub const mjtPluginCapabilityBit = enums.PluginCapabilityFlag;

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

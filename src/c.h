#include <mujoco/mujoco.h>


// Mujoco simulate Copyright (c) 2025 David Hožič
// Dual MIT and Apache License
typedef struct mujoco_Simulate mujoco_Simulate;

#ifdef __cplusplus
extern "C" {
#endif

mujoco_Simulate* mujoco_cSimulate_create(
    mjvCamera* cam,
    mjvOption* opt,
    mjvPerturb* pert,
    mjvScene* user_scn
);

void mujoco_cSimulate_Load(
    mujoco_Simulate* sim,
    mjModel* m,
    mjData* d,
    const char* displayed_filename
);

int mujoco_cSimulate_RenderLoop(mujoco_Simulate* sim);

void mujoco_cSimulate_Sync(mujoco_Simulate* sim, int state_only);

void mujoco_cSimulate_ExitRequest(mujoco_Simulate* sim);

int mujoco_cSimulate_ShouldExit(mujoco_Simulate* sim);

void mujoco_cSimulate_destroy(mujoco_Simulate* sim);

#ifdef __cplusplus
}
#endif

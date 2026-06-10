// Copyright (c) 2025 David Hožič
// Copyright (c) 2026 Oscar Labrada-Love
// Dual MIT and Apache License

#include "simulate_c.h"
#include "simulate.h"
#include "glfw_adapter.h"
#include <memory>

extern "C" mujoco_Simulate* mujoco_cSimulate_create(
    mjvCamera* cam,
    mjvOption* opt,
    mjvPerturb* pert,
    mjvScene* user_scn
) {
    auto adapter = std::make_unique<mujoco::GlfwAdapter>();
    // cast to mujoco_Simulate* for the C API
    auto sim = new mujoco::Simulate(std::move(adapter), cam, opt, pert, true);
    sim->user_scn = user_scn;
    return reinterpret_cast<mujoco_Simulate*>(sim);
}

extern "C" void mujoco_cSimulate_Load(
    mujoco_Simulate* sim_c, 
    mjModel* m, 
    mjData* d, 
    const char* displayed_filename
) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    sim->Load(m, d, displayed_filename);
}

extern "C" int mujoco_cSimulate_RenderLoop(mujoco_Simulate* sim_c) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    sim->RenderLoop();
    return 0;
}

extern "C" void mujoco_cSimulate_Sync(mujoco_Simulate* sim_c, int state_only) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    sim->Sync(state_only != 0);
}

extern "C" void mujoco_cSimulate_ExitRequest(mujoco_Simulate* sim_c) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    sim->exitrequest.store(1);
    sim->cond_loadrequest.notify_all();
}

extern "C" int mujoco_cSimulate_ShouldExit(mujoco_Simulate* sim_c) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    return sim->exitrequest.load();
}

extern "C" void mujoco_cSimulate_destroy(mujoco_Simulate* sim_c) {
    auto sim = reinterpret_cast<mujoco::Simulate*>(sim_c);
    delete sim;
}

// this file can be ignored, it's used for my current folder plugins that I care about enough to put here :xdd:

namespace tm_AutoEnableSpecificGhost { import void RenderMenu() from "tm_Auto-Enable-Specific-Ghost"; }
namespace tm_ArbitraryRecordLoader { import void RenderMenu() from "tm_Arbitrary-Record-Loader"; }

bool HasManualRender(const string &in p) {
    if (p == "tm_Auto-Enable-Specific-Ghost") return true;
    if (p == "tm_Arbitrary-Record-Loader") return true;

    return false;
}

void CallManualRender(const string &in p) {
    if (p == "tm_Auto-Enable-Specific-Ghost") {
        try { tm_AutoEnableSpecificGhost::RenderMenu(); } catch {}
    } 
    if (p == "tm_Arbitrary-Record-Loader") {
        try { tm_ArbitraryRecordLoader::RenderMenu(); } catch {}
    }
}

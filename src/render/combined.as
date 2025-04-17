bool HasRender(const string &in p) {
    if (HasManualRender(p)) return true;
    if (HasAutoRender(p)) return true;
    return false;
}

void CallRender(const string &in p) {
    if (HasManualRender(p)) {
        CallManualRender(p);
        return;
    }
    if (HasAutoRender(p)) {
        CallAutoRender(p);
    }
}

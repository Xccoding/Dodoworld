declare interface CScriptBindingPR_Abilities {
    GetMaxAbilityCharges: Function;
    GetCurrentAbilityCharges: Function;
    GetAbilityChargeRestoreTimeRemaining: Function;
}

declare interface CustomUIConfig {
    SchoolsKv: {
        [k: string]: any;
    };
    AbilityKv: {
        [k: string]: any;
    };
    HeroesKv: {
        [k: string]: any;
    };
    TalentsKv: {
        [k: string]: any;
    }
    HudRoot: Panel;
}

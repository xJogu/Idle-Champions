; GameManager class contains the in game data structure layout

; GameManager class contains the offsets as found in mono-disected memory structures. Specifically, the offsets for the IdleGameManager structure.
; It was designed to make future updates easier by clarifying where each offset is found and (hopefully) reduce the difficulty of updating offsets for structures that remain largely the same.
; - Variable names are based on the layout within the structure not including GameManager itself. e.g. this.Game.GameUser will be IdleGameManager->Game->GameUser.
; - Each offset is built off of a previous offsets. e.g. this.Game.GameUser.ID will be this.game.GameUser + ID, or IdleGameManager->Game->GameUser->ID
; - GameObjectStructure is what is used to combine offsets.
; - Items defined by "List" will have an Item[x] offset that is dynamically selected in code via object.GetGameObjectFromListValues(x).
; - There can be multiple missing list offsets as the game can traverse multiple lists to get to the value you want.
; - i.e. Instead of using:
;            this.Game.GameInstance.Controller.UserData.HeroHandler.HeroList.UpgradeCount
;   you would use
;            this.Game.GameInstance.Controller.UserData.HeroHandler.HeroList.UpgradeCount.GetGameObjectFromListValues( hero_id )
;   as hero_id will tell it which hero from the HeroList is being accessed.
;   Each extra list used will require an extra location passed. e.g. GetGameObjectFromListValues( first_id, second_id, third_id )

#include %A_LineFile%\..\IC_GameObjectStructure_Class.ahk

class IC_GameManager_Class
{
    __new()
    {
        this.Refresh()
    }

    GetVersion()
    {
        return "v1.10.11, 2022-04-16, IC v0.430+, Steam"
    }

    is64Bit()
    {
        return this.Main.isTarget64bit
    }

    Refresh()
    {
        ;Open a process with sufficient access to read and write memory addresses (this is required before you can use the other functions)
        ;You only need to do this once. But if the process closes/restarts, then you will need to perform this step again. Refer to the notes section below.
        ;Also, if the target process is running as admin, then the script will also require admin rights!
        ;Note: The program identifier can be any AHK windowTitle i.e.ahk_exe, ahk_class, ahk_pid, or simply the window title.
        ;hProcessCopy is an optional variable in which the opened handled is stored.
        ;==================
        ;structure pointers
        ;==================
        this.Main := new _ClassMemory("ahk_exe IdleDragons.exe", "", hProcessCopy)
        this.BaseAddress := this.Main.getModuleBaseAddress("mono-2.0-bdwgc.dll")+0x003A0574
        this.GameManager := New GameObjectStructure([0x658])
        this.GameManager.BaseAddress := this.BaseAddress
        #include %A_LineFile%\..\IC_IdleGameManager32_Export.ahk

    }
}

class IC_GameManagerEGS_Class
{
    __new()
    {
        this.Refresh()
    }

    GetVersion()
    {
        return "v1.9.16, 2022-04-09, IC v0.428+, EGS"
    }

    is64Bit()
    {
        return this.Main.isTarget64bit
    }

    Refresh()
    {
        ;==================
        ;structure pointers
        ;==================
        this.Main := new _ClassMemory("ahk_exe IdleDragons.exe", "", hProcessCopy)
        this.BaseAddress := this.Main.getModuleBaseAddress("mono-2.0-bdwgc.dll")+0x00491A90
        this.IdleGameManager := New GameObjectStructure([0xC88])
        this.IdleGameManager.Is64Bit := true
        this.IdleGameManager.BaseAddress := this.BaseAddress
        #include %A_LineFile%\..\IC_IdleGameManager64_Export.ahk
    }
}
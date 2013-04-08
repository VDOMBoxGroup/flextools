// ActionScript file

@startuml img/sequence_img001.png
participant  Core #MistyRose
title Run  IDEModule public function by  IDECore

note over of Core:  	ModuleManager is ready

Core -> Mod1 : startup()

note over of Mod1:  	do samething
note left of Core:  	User logined
note over of Core:  	Switch on tab \ncontained Mod1

Core -> Mod1 : getToolset()
Core -> Mod1 : deSelect()

note right of Mod1:  	Deseleted all modules
note over of Core:  	Select Mod1

Core -> Mod1 : getBody() 

note over of Core:  	Deselect Mod1

Core -> Mod1 : deSelect()  ( to all Mod )

note  over of Core:  User logOff

Core -> Mod1 :  tearDown() ( to all Mod ) 
	
@enduml	
/*@startumlimg/
sequence_img001.png
Builder.mxml - > ProgressManager
:
start
\
n( ProgressManager.WINDOW_MODE, false )
Builder.mxml - > ContextManager
:
ContextManager - > TemplateStruct
:
generate()

@enduml
*/
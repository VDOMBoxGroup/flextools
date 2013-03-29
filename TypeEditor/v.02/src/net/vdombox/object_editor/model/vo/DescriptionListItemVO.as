package net.vdombox.object_editor.model.vo
{
import net.vdombox.object_editor.view.DescriptionUpdateView;

public class DescriptionListItemVO
    {

        public var displayName : String;
        public var data : BaseVO;

        public var descriptionUpdateView : DescriptionUpdateView;

        [Bindable]
        public var checked : Boolean;

        public function DescriptionListItemVO ()
        {
        }
    }
}

package net.vdombox.object_editor.model.vo
{
import net.vdombox.object_editor.view.DescriptionUpdateView;

public class DescriptionListItemVO
{
	[Bindable]
	public var oldValue : String;
	[Bindable]
	public var newValue : String;

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

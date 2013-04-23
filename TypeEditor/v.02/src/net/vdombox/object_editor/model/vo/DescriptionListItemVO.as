package net.vdombox.object_editor.model.vo
{
import net.vdombox.object_editor.view.DescriptionUpdateView;

public class DescriptionListItemVO
{
	private var _oldValue : String = "";
	public function set oldValue( value : String ) : void
	{
		if (value == _oldValue)
			return;

		_oldValue = value;

		if (descriptionUpdateView)
			descriptionUpdateView.oldValue = _oldValue;
	}

	public function get oldValue() : String
	{
		return _oldValue;
	}

	private var _newValue : String = "";
	public function set newValue( value : String ) : void
	{
		if (value == _newValue)
			return;

		_newValue = value;

		if (descriptionUpdateView)
			descriptionUpdateView.newValue = _newValue;
	}

	public function get newValue() : String
	{
		return _newValue;
	}


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

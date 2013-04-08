/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 13.07.12
 * Time: 18:14
 */
package net.vdombox.proshare.model
{
import net.vdombox.proshare.connection.protect.MD5;

public class FileVO
{

	private var _spaceVO : SpaceVO;

	private var _guid : String;
	private var _title : String;
	private var description : String;
	private var last_use_time : String;
	private var _spaceID : String;
	private var _size : Number;
	private var preview_file : String;
	private var date : String;
	private var pdf_file : String;
	private var big_preview : String;
	private var thumbnail : String;



	public function FileVO( value : XML )
	{
		_guid =   value.cell[1];
		_title =   value.cell[2];
		description =   value.cell[3];
		last_use_time =   value.cell[4];
		_spaceID =   value.cell[5];
		_size =   Number(value.cell[6]);
		preview_file =   value.cell[7];
		date =   value.cell[8];
		pdf_file =   value.cell[9];
		big_preview =   value.cell[10];
		thumbnail =   value.cell[11];
//		_guid =   value.cell[1];
//		_guid =   value.cell[1];

	}


	public function get hash():String
	{
		var str : String = "";

		if (spaceVO )
			str = _guid + _spaceID  + spaceVO.pwdWrite + spaceVO.pwdRead;


		return MD5.encrypt(str);
	}

	public function get vars(  ):String
	{
//		/get_file.vdom?guid=21a418f7-3696-4754-8b04-5bb519a196fd&access=7bf81fb4562eeb4f79aafb2fc0346734
		return "guid=" + _guid + "&access="+ hash;
	}

	public function get spaceVO():SpaceVO
	{
		return _spaceVO;
	}

	public function set spaceVO( value:SpaceVO ):void
	{
		_spaceVO = value;
	}

	public function get guid():String
	{
		return _guid;
	}

	public function get title():String
	{
		return _title;
	}

	public function get size():Number
	{
		return _size;
	}

	public function get sizeString():String
	{
		var s : Number = Math.round( _size / 1024.0/1024.0*1000)/1000;
		return    s.toString() + " MB" ;
	}

	public function get spaceID():String
	{
		return _spaceID;
	}


}
}

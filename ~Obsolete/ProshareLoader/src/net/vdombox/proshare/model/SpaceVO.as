/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 13.07.12
 * Time: 16:50
 */
package net.vdombox.proshare.model
{
public class SpaceVO
{

	private var _name : String;
	private var _pwdRead : String;
	private var _pwdWrite : String;
	private var _guid : String;
	private var _description : String;
	private var date : String;
	private var _user : String;
	private var _limit : String;

	private var filesVO : Vector.<FileVO> = new Vector.<FileVO>;

	public function SpaceVO( value : XML )
	{
		_name =  value.cell[1];
		_pwdRead =  value.cell[2];
		_pwdWrite =  value.cell[3];
		_guid =  value.cell[4];
		_description =  value.cell[5];
		date =  value.cell[6];
		_user =  value.cell[7];
		_limit =  value.cell[8];
//		_name =  value.cell[1];


	}

	public function addFileVO( fileVO : FileVO ): void
	{
		fileVO.spaceVO = this;
		filesVO.push( fileVO );
	}


	public function get user():String
	{
		return _user;
	}

	public function get limit():String
	{
		return _limit;
	}


	public function get name():String
	{
		return _name;
	}

	public function get guid():String
	{
		return _guid;
	}

	public function get description():String
	{
		return _description;
	}

	public function get pwdWrite():String
	{
		return _pwdWrite;
	}

	public function get pwdRead():String
	{
		return _pwdRead;
	}
}
}

package ro.victordramba.util
{
	public function vectorToArray(v:Object):Array
	{
		var a:Array = [];
		for (var i:int=0; i<v.length; i++)
			a[i] = v[i];
		return a;
	}
}
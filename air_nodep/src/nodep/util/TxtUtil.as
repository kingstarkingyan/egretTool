package nodep.util
{
	/**
	 * 文本工具
	 * @author nodep
	 */	
	public class TxtUtil
	{
		public static function replace(str:String,key:String,value:String):String{
			var startIndex:int = str.indexOf(key);
			var subString:String = str.substr(startIndex);
			var index2:int = subString.indexOf("\"");
			var index3:int = subString.indexOf("\"",index2+2);
			var oldStart:int = startIndex;
			startIndex = startIndex+index2;
			var endIndex:int = oldStart+index3;
			var fontStr:String = str.substr(0,startIndex);
			var backStr:String = str.substr(endIndex);
			return fontStr+"\""+value+backStr;
		}
	}
}
package nodep.ui
{
	import flash.display.Stage;

	/**
	 * 界面管理器
	 * @author nodep
	 */	
	public class WinsManager
	{
		public static var stage:Stage;
		/**
		 * 初始化界面
		 * @param sdg
		 */		
		public static function init(sdg:Stage):void
		{
			stage = sdg;
		}
	}
}
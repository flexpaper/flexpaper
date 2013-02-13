package com.devaldi.controls.flexpaper.utils
{
	import mx.resources.IResourceManager;

	public class ResourceUtil
	{
		public static function getResource(resourceName:String, rm:IResourceManager):String{
			var res:String = rm.getString("FlexPaper",resourceName);
			
			if(res==null||(res!=null&&res.length==0)){
				res = rm.getString("FlexPaper",resourceName,null,"en_US");
			}
			
			return res;
		}
	}
}
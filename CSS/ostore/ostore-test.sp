#include <sourcemod>
#include <ostore>

public Plugin:myinfo =
{
	name = "OStore 商店系统",
	author = "Hao",
	description = "OStore 测试组件",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	new Handle:hCategory_1;
	new Handle:hCategory_2;
	RegOStoreCategory("分类1", "测试分类 1", hCategory_1);
	RegOStoreCategory("分类2", "测试分类 2", hCategory_2);
	
	new Handle:hProduct_1;
	new Handle:hProduct_2;
	RegOStoreProduct("产品1", "测试产品 1", hProduct_1);
	RegOStoreProduct("产品2", "测试产品 2", hProduct_2);
	
	LinkOStoreProductToCategory(hProduct_1, hCategory_1);
	LinkOStoreProductToCategory(hProduct_2, hCategory_2);
	
	new Handle:hProduct_1_Type_1;
	new Handle:hProduct_1_Type_2;
	new Handle:hProduct_1_Type_3;
	RegOStoreProductType(hProduct_1, 200, _, _, _, hProduct_1_Type_1);
	RegOStoreProductType(hProduct_1, 100, OSTORE_PRODUCT_TYPE_VALIDITY, _, 200, hProduct_1_Type_2);
	RegOStoreProductType(hProduct_1, 50, OSTORE_PRODUCT_TYPE_AMOUNT, 200, _, hProduct_1_Type_3);
	
	new Handle:hProduct_2_Type_1;
	new Handle:hProduct_2_Type_2;
	new Handle:hProduct_2_Type_3;
	RegOStoreProductType(hProduct_2, 100, _, _, _, hProduct_2_Type_1);
	RegOStoreProductType(hProduct_2, 50, OSTORE_PRODUCT_TYPE_VALIDITY, _, 100, hProduct_2_Type_2);
	RegOStoreProductType(hProduct_2, 25, OSTORE_PRODUCT_TYPE_AMOUNT, 100, _, hProduct_2_Type_3);
	
	PrintToServer("[REGISTER] OK");
}

public OnClientPutInServer(client)
{
	new point;
	GetOStoreAccountPoint(client, point);
	SetOStoreAccountPoint(client, point + 100);
}
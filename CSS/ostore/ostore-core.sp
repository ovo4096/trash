#include <sourcemod>

public Plugin:myinfo =
{
	name = "OStore 商店系统",
	author = "Hao",
	description = "OStore 核心组件",
	version = "1.0",
	url = ""
};

new Handle:OStoreGlobalDb = INVALID_HANDLE; // 全局数据库句柄

#define OSTORE_PRODUCT_TYPE_AMOUNT			"amount"
#define OSTORE_PRODUCT_TYPE_VALIDITY		"validity"
#define OSTORE_PRODUCT_TYPE_FOREVER			"forever"

#define OSTORE_NAME_MAX_LENGTH				(255)
#define OSTORE_DETAIL_MAX_LENGTH			(255)
#define OSTORE_TYPE_MAX_LENGTH				(20)
#define OSTORE_VALIDITY_MAX_LENGTH			(20)

#define DATE_TIME_EQUAL 					(0)
#define DATE_TIME_GT    					(1)
#define DATE_TIME_LT    					(2)

new Handle:hIsExistOStoreAccount = INVALID_HANDLE;
new Handle:hCreateOStoreAccount = INVALID_HANDLE;
new Handle:hDeleteOStoreAccount = INVALID_HANDLE;
new Handle:hDeleteOStoreAccountAllProduct = INVALID_HANDLE;
new Handle:hSetOStoreAccountPoint = INVALID_HANDLE;
new Handle:hGetOStoreAccountPoint = INVALID_HANDLE;
new Handle:hFindOStoreProduct = INVALID_HANDLE;
new Handle:hUpdateOStoreProduct = INVALID_HANDLE;
new Handle:hCreateOStoreProduct = INVALID_HANDLE;
new Handle:hDeleteOStoreProductFromCategory = INVALID_HANDLE;
new Handle:hDeleteOStoreProductFromAccount = INVALID_HANDLE;
new Handle:hDeleteOStoreProduct = INVALID_HANDLE;
new Handle:hFindOStoreCategory = INVALID_HANDLE;
new Handle:hUpdateOStoreCategory = INVALID_HANDLE;
new Handle:hCreateOStoreCategory = INVALID_HANDLE;
new Handle:hDeleteOStoreCategoryFromProduct = INVALID_HANDLE;
new Handle:hDeleteOStoreCategory = INVALID_HANDLE;
new Handle:hMoveOStoreProductToCategory = INVALID_HANDLE;
new Handle:hFindOStoreProductFromCategory = INVALID_HANDLE;
new Handle:hLinkOStoreProductToCategory = INVALID_HANDLE;
new Handle:hCreateOStoreProductType = INVALID_HANDLE;
new Handle:hGetAllOStoreCategory = INVALID_HANDLE;
new Handle:hGetAllOStoreCategoryProduct = INVALID_HANDLE;
new Handle:hGetCategoryInfo = INVALID_HANDLE;
new Handle:hGetProductName = INVALID_HANDLE;
new Handle:hGetOStoreProductInfo = INVALID_HANDLE;
new Handle:hGetAllOStoreProductType = INVALID_HANDLE;
new Handle:hGetOStoreProductTypeInfo = INVALID_HANDLE;
new Handle:hGetOStoreAccountProductInfo = INVALID_HANDLE;
new Handle:hCreateOStoreAccountProduct = INVALID_HANDLE;
new Handle:hUpdateOStoreAccountProduct = INVALID_HANDLE;
new Handle:hDeleteOStoreAccountProduct = INVALID_HANDLE;
new Handle:hFindOStoreProductType = INVALID_HANDLE; 
new Handle:hGetLastInsertId = INVALID_HANDLE;
new Handle:hDeleteOStoreProductType = INVALID_HANDLE;
new Handle:hGetOStoreAccountProductInfo2 = INVALID_HANDLE;
new Handle:hDecOStoreAccountProductAmount = INVALID_HANDLE;

new ClientSeletctPrevMenuIndex[MAXPLAYERS];

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("FindOStoreCategory", Native_FindOStoreCategory);
	CreateNative("FindOStoreProduct", Native_FindOStoreProduct);
	CreateNative("LinkOStoreProductToCategory", Native_LinkOStoreProductToCategory);
	CreateNative("RegOStoreCategory", Native_RegOStoreCategory);
	CreateNative("RegOStoreProduct", Native_RegOStoreProduct);
	CreateNative("RegOStoreProductType", Native_RegOStoreProductType);
	CreateNative("UnRegOStoreCategory", Native_UnRegOStoreCategory);
	CreateNative("UnRegOStoreProduct", Native_UnRegOStoreProduct);
	CreateNative("UnRegOStoreProductType", Native_UnRegOStoreProductType);
	CreateNative("UseOStoreProduct", Native_UseOStoreProduct);
	
	CreateNative("IsOStoreAccountExist", Native_IsOStoreAccountExist);
	CreateNative("CreateOStoreAccount", Native_CreateOStoreAccount);
	CreateNative("DeleteOStoreAccount", Native_DeleteOStoreAccount);
	CreateNative("SetOStoreAccountPoint", Native_SetOStoreAccountPoint);
	CreateNative("GetOStoreAccountPoint", Native_GetOStoreAccountPoint);
	CreateNative("BuyOStoreProduct", Native_BuyOStoreProduct);
	return APLRes_Success;
}

// native bool:FindOStoreCategory(const String:name[], &Handle:hCategory=INVALID_HANDLE);
public Native_FindOStoreCategory(Handle:plugin, numParams) 
{
	new length;
	GetNativeStringLength(1, length);
	
	decl String:name[length + 1];
	GetNativeString(1, name, length + 1);
	
	new Handle:hCategory = Handle:GetNativeCellRef(2);
	
	new bool:result = FindOStoreCategory(name, hCategory);
	
	SetNativeCellRef(2, hCategory);
	
	return result;
}

// native bool:FindOStoreProduct(const String:name[], &Handle:hProduct=INVALID_HANDLE);
public Native_FindOStoreProduct(Handle:plugin, numParams) 
{
	new length;
	GetNativeStringLength(1, length);
	
	decl String:name[length + 1];
	GetNativeString(1, name, length + 1);
	
	new Handle:hProduct = Handle:GetNativeCellRef(2);
	
	new bool:result = FindOStoreProduct(name, hProduct);
	
	SetNativeCellRef(2, hProduct);
	
	return result;
}

// native bool:LinkOStoreProductToCategory(Handle:hProduct, Handle:hCategory);
public Native_LinkOStoreProductToCategory(Handle:plugin, numParams) 
{
	new Handle:hProduct = Handle:GetNativeCell(1);
	new Handle:hCategory = Handle:GetNativeCell(2);
	
	return LinkOStoreProductToCategory(hProduct, hCategory);
}

// native bool:RegOStoreCategory(const String:name[], const String:detail[], &Handle:hCategory=INVALID_HANDLE);
public Native_RegOStoreCategory(Handle:plugin, numParams) 
{
	new length;
	GetNativeStringLength(1, length);
	decl String:name[length + 1];
	GetNativeString(1, name, length + 1);
	
	GetNativeStringLength(2, length);
	decl String:detail[length + 1];
	GetNativeString(2, detail, length + 1);
	
	new Handle:hCategory = GetNativeCellRef(3);
	new bool:result = RegOStoreCategory(name, detail, hCategory);
	SetNativeCellRef(3, hCategory);
	
	return result;
}

// native bool:RegOStoreProduct(const String:name[], const String:detail[], &Handle:hProduct=INVALID_HANDLE);
public Native_RegOStoreProduct(Handle:plugin, numParams) 
{
	new length;
	GetNativeStringLength(1, length);
	decl String:name[length + 1];
	GetNativeString(1, name, length + 1);
	
	GetNativeStringLength(2, length);
	decl String:detail[length + 1];
	GetNativeString(2, detail, length + 1);
	
	new Handle:hProduct = GetNativeCellRef(3);
	new bool:result = RegOStoreProduct(name, detail, hProduct);
	SetNativeCellRef(3, hProduct);
	
	return result;
}

// native bool:RegOStoreProductType(Handle:hProduct, point, const String:type[]=OSTORE_PRODUCT_TYPE_FOREVER, amount=0, second=0, &Handle:hProductType=INVALID_HANDLE);
public Native_RegOStoreProductType(Handle:plugin, numParams) 
{
	new Handle:hProduct = Handle:GetNativeCell(1);
	new point = GetNativeCell(2);
	
	new length;
	GetNativeStringLength(3, length);
	decl String:type[length + 1];
	GetNativeString(3, type, length + 1);
	
	new amount = GetNativeCell(4);
	new second = GetNativeCell(5);
	
	new Handle:hProductType = GetNativeCellRef(6);
	
	new bool:result = RegOStoreProductType(hProduct, point, type, amount, second, hProductType);
	
	SetNativeCellRef(6, hProductType);
	
	return result;
}

// native bool:UnRegOStoreCategory(Handle:hCategory);
public Native_UnRegOStoreCategory(Handle:plugin, numParams) 
{
	new Handle:hCategory = Handle:GetNativeCell(1);
	
	return UnRegOStoreCategory(hCategory);
}

// native bool:UnRegOStoreProduct(const Handle:hProduct);
public Native_UnRegOStoreProduct(Handle:plugin, numParams) 
{
	new Handle:hProduct = Handle:GetNativeCell(1);
	
	return UnRegOStoreProduct(hProduct);
}

// native bool:UnRegOStoreProductType(Handle:hProductType);
public Native_UnRegOStoreProductType(Handle:plugin, numParams) 
{
	new Handle:hProductType = Handle:GetNativeCell(1);
	
	return UnRegOStoreProductType(hProductType);
}

// native bool:UseOStoreProduct(client, Handle:hProduct);
public Native_UseOStoreProduct(Handle:plugin, numParams) 
{
	new client = GetNativeCell(1);
	new Handle:hProduct = Handle:GetNativeCell(2);
	
	return UseOStoreProduct(client, hProduct);
}

// native bool:IsOStoreAccountExist(client, &bool:isExist=false);
public Native_IsOStoreAccountExist(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new bool:isExist = bool:GetNativeCellRef(2);
	new bool:result = IsOStoreAccountExist(client, isExist);
	SetNativeCellRef(2, isExist);
	return result;
}

// native bool:CreateOStoreAccount(client);
public Native_CreateOStoreAccount(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	return CreateOStoreAccount(client);
}

// native bool:DeleteOStoreAccount(client);
public Native_DeleteOStoreAccount(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	return DeleteOStoreAccount(client);
}

// native bool:SetOStoreAccountPoint(client, point);
public Native_SetOStoreAccountPoint(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new point = GetNativeCell(2);
	return SetOStoreAccountPoint(client, point);
}

// native bool:GetOStoreAccountPoint(client, &point=0);
public Native_GetOStoreAccountPoint(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new point = GetNativeCellRef(2);
	new bool:result = GetOStoreAccountPoint(client, point);
	SetNativeCellRef(2, point);
	return result;
}

// native bool:BuyOStoreProduct(client, Handle:hProductType);
public Native_BuyOStoreProduct(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new Handle:hProductType = Handle:GetNativeCell(2);
	return BuyOStoreProduct(client, hProductType);
}

PrintSQLErrorToServer(Handle:db)
{
	decl String:error[255];
	SQL_GetError(db, error, sizeof(error));
	PrintToServer("[OStore] SQL Error: %s", error);
}

bool:IsOStoreAccountExist(client, &bool:isExist=false)
{
	isExist = false;

	if (hIsExistOStoreAccount == INVALID_HANDLE)
	{
		decl String:error[255];
		hIsExistOStoreAccount = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id` FROM `ostore_accounts` WHERE `id` = ?", error, sizeof(error));
		
		if (hIsExistOStoreAccount == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	new steamId = GetSteamAccountID(client);
	SQL_BindParamInt(hIsExistOStoreAccount, 0, steamId);
	
	if (!SQL_Execute(hIsExistOStoreAccount))
	{
		PrintSQLErrorToServer(hIsExistOStoreAccount);
		return false;
	}
	
	if (SQL_GetRowCount(hIsExistOStoreAccount) != 0)
	{
		isExist = true;
	}
	
	return true;
}

bool:CreateOStoreAccount(client)
{
	if (hCreateOStoreAccount == INVALID_HANDLE)
	{
		decl String:error[255];
		hCreateOStoreAccount = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_accounts` (`id`) VALUES (?)", error, sizeof(error));
		
		if (hCreateOStoreAccount == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	new steamId = GetSteamAccountID(client);
	SQL_BindParamInt(hCreateOStoreAccount, 0, steamId);
	
	if (!SQL_Execute(hCreateOStoreAccount))
	{
		PrintSQLErrorToServer(hCreateOStoreAccount);
		return false;
	}

	return true;
}

bool:DeleteOStoreAccount(client)
{
	// 这里最好改为事务处理，先这样吧。。。。
	decl String:error[255];
	if (hDeleteOStoreAccount == INVALID_HANDLE)
	{
		hDeleteOStoreAccount = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_accounts` WHERE `ostore_accounts`.`id` = ?", error, sizeof(error));
		
		if (hDeleteOStoreAccount == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	if (hDeleteOStoreAccountAllProduct == INVALID_HANDLE)
	{
		hDeleteOStoreAccountAllProduct = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_accounts_products` WHERE `ostore_accounts_products`.`account_id` = ?", error, sizeof(error));
		
		if (hDeleteOStoreAccountAllProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	new steamId = GetSteamAccountID(client);
	SQL_BindParamInt(hDeleteOStoreAccount, 0, steamId);
	SQL_BindParamInt(hDeleteOStoreAccountAllProduct, 0, steamId);
	
	if (!SQL_Execute(hDeleteOStoreAccount))
	{
		PrintSQLErrorToServer(hDeleteOStoreAccount);
		return false;
	}
	
	if (!SQL_Execute(hDeleteOStoreAccountAllProduct))
	{
		PrintSQLErrorToServer(hDeleteOStoreAccountAllProduct);
		return false;
	}
	
	return true;
}

bool:SetOStoreAccountPoint(client, point)
{
	if (hSetOStoreAccountPoint == INVALID_HANDLE)
	{
		decl String:error[255];
		hSetOStoreAccountPoint = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_accounts` SET `point` = ? WHERE `ostore_accounts`.`id` = ?", error, sizeof(error));
		
		if (hSetOStoreAccountPoint == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	new steamId = GetSteamAccountID(client);
	SQL_BindParamInt(hSetOStoreAccountPoint, 0, point);
	SQL_BindParamInt(hSetOStoreAccountPoint, 1, steamId);

	if (!SQL_Execute(hSetOStoreAccountPoint))
	{
		PrintSQLErrorToServer(hSetOStoreAccountPoint);
		return false;
	}
	
	return true;
}

bool:GetOStoreAccountPoint(client, &point=0)
{
	if (hGetOStoreAccountPoint == INVALID_HANDLE)
	{
		decl String:error[255];
		hGetOStoreAccountPoint = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `point` FROM `ostore_accounts` WHERE `id` = ?", error, sizeof(error));
		
		if (hGetOStoreAccountPoint == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	new steamId = GetSteamAccountID(client);
	SQL_BindParamInt(hGetOStoreAccountPoint, 0, steamId);
	
	if (!SQL_Execute(hGetOStoreAccountPoint))
	{
		PrintSQLErrorToServer(hGetOStoreAccountPoint);
		return false;
	}
	
	while (SQL_FetchRow(hGetOStoreAccountPoint))
	{
		point = SQL_FetchInt(hGetOStoreAccountPoint, 0);
	}
	
	return true;
}

bool:FindOStoreProduct(const String:name[], &Handle:hProduct=INVALID_HANDLE)
{
	if (hFindOStoreProduct == INVALID_HANDLE)
	{
		decl String:error[255];
		hFindOStoreProduct = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id` FROM `ostore_products` WHERE `name` = ?", error, sizeof(error));
		if (hFindOStoreProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamString(hFindOStoreProduct, 0, name, false);
	
	if (!SQL_Execute(hFindOStoreProduct))
	{
		PrintSQLErrorToServer(hFindOStoreProduct);
		return false;
	}
	
	while (SQL_FetchRow(hFindOStoreProduct))
	{
		hProduct = Handle:SQL_FetchInt(hFindOStoreProduct, 0);
	}
	
	return true;
}

bool:RegOStoreProduct(const String:name[], const String:detail[], &Handle:hProduct=INVALID_HANDLE)
{
	// 查找商品是否存在 存在 更新 不存在 创建 返回 句柄
	
	if (!FindOStoreProduct(name, hProduct))
	{
		return false;
	}
	
	new bool:isFind = hProduct != INVALID_HANDLE ? true : false;
	
	decl String:error[255];
	
	if (isFind)
	{
		if (hUpdateOStoreProduct == INVALID_HANDLE)
		{
			hUpdateOStoreProduct = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_products` SET `detail` = ? WHERE `ostore_products`.`name` = ?", error, sizeof(error));
			
			if (hUpdateOStoreProduct == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamString(hUpdateOStoreProduct, 0, detail, false);
		SQL_BindParamString(hUpdateOStoreProduct, 1, name, false);
		
		if (!SQL_Execute(hUpdateOStoreProduct))
		{
			PrintSQLErrorToServer(hUpdateOStoreProduct);
			return false;
		}
	}
	else
	{
		if (hCreateOStoreProduct == INVALID_HANDLE)
		{
			hCreateOStoreProduct = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_products` (`name`, `detail`) VALUES (?, ?)", error, sizeof(error));
			
			if (hCreateOStoreProduct == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamString(hCreateOStoreProduct, 0, name, false);
		SQL_BindParamString(hCreateOStoreProduct, 1, detail, false);
		
		if (!SQL_Execute(hCreateOStoreProduct))
		{
			PrintSQLErrorToServer(hCreateOStoreProduct);
			return false;
		}
		
		if (!FindOStoreProduct(name, hProduct))
		{
			return false;
		}
	}
	
	return true;
}

bool:UnRegOStoreProduct(const Handle:hProduct)
{
	decl String:error[255];
	
	if (hDeleteOStoreProductFromCategory == INVALID_HANDLE)
	{
		hDeleteOStoreProductFromCategory = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_products_categories` WHERE `ostore_products_categories`.`product_id` = ?", error, sizeof(error));
		if (hDeleteOStoreProductFromCategory == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	if (hDeleteOStoreProductFromAccount == INVALID_HANDLE)
	{
		hDeleteOStoreProductFromAccount = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_accounts_products` WHERE `ostore_accounts_products`.`product_id` = ?", error, sizeof(error));
		if (hDeleteOStoreProductFromAccount == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	if (hDeleteOStoreProduct == INVALID_HANDLE)
	{
		hDeleteOStoreProduct = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_products` WHERE `ostore_products`.`id` = ?", error, sizeof(error));
		if (hDeleteOStoreProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hDeleteOStoreProductFromCategory, 0, _:hProduct);
	
	if (!SQL_Execute(hDeleteOStoreProductFromCategory))
	{
		PrintSQLErrorToServer(hDeleteOStoreProductFromCategory);
		return false;
	}
	
	
	SQL_BindParamInt(hDeleteOStoreProductFromAccount, 0, _:hProduct);
	
	if (!SQL_Execute(hDeleteOStoreProductFromAccount))
	{
		PrintSQLErrorToServer(hDeleteOStoreProductFromAccount);
		return false;
	}
	
	SQL_BindParamInt(hDeleteOStoreProduct, 0, _:hProduct);
	
	if (!SQL_Execute(hDeleteOStoreProduct))
	{
		PrintSQLErrorToServer(hDeleteOStoreProduct);
		return false;
	}
	
	return true;
}

bool:FindOStoreCategory(const String:name[], &Handle:hCategory=INVALID_HANDLE)
{
	if (hFindOStoreCategory == INVALID_HANDLE)
	{
		decl String:error[255];
		hFindOStoreCategory = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id` FROM `ostore_categories` WHERE `name` = ?", error, sizeof(error));
		if (hFindOStoreCategory == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamString(hFindOStoreCategory, 0, name, false);
	
	if (!SQL_Execute(hFindOStoreCategory))
	{
		PrintSQLErrorToServer(hFindOStoreCategory);
		return false;
	}
	
	while (SQL_FetchRow(hFindOStoreCategory))
	{
		hCategory = Handle:SQL_FetchInt(hFindOStoreCategory, 0);
	}
	
	return true;
}

bool:RegOStoreCategory(const String:name[], const String:detail[], &Handle:hCategory=INVALID_HANDLE)
{
	if (!FindOStoreCategory(name, hCategory))
	{
		return false;
	}
	
	new bool:isFind = hCategory != INVALID_HANDLE ? true : false;
	
	decl String:error[255];
	
	if (isFind)
	{
		if (hUpdateOStoreCategory == INVALID_HANDLE)
		{
			hUpdateOStoreCategory = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_categories` SET `detail` = ? WHERE `ostore_categories`.`name` = ?", error, sizeof(error));
			if (hUpdateOStoreCategory == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamString(hUpdateOStoreCategory, 0, detail, false);
		SQL_BindParamString(hUpdateOStoreCategory, 1, name, false);
		
		if (!SQL_Execute(hUpdateOStoreCategory))
		{
			PrintSQLErrorToServer(hUpdateOStoreCategory);
			return false;
		}
	}
	else
	{
		if (hCreateOStoreCategory == INVALID_HANDLE)
		{
			hCreateOStoreCategory = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_categories` (`name`, `detail`) VALUES (?, ?)", error, sizeof(error));
			if (hCreateOStoreCategory == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamString(hCreateOStoreCategory, 0, name, false);
		SQL_BindParamString(hCreateOStoreCategory, 1, detail, false);
		
		if (!SQL_Execute(hCreateOStoreCategory))
		{
			PrintSQLErrorToServer(hCreateOStoreCategory);
			return false;
		}
		
		if (!FindOStoreCategory(name, hCategory))
		{
			return false;
		}
	}
	
	return true;
}

bool:UnRegOStoreCategory(Handle:hCategory)
{
	decl String:error[255];
	
	if (hDeleteOStoreCategoryFromProduct == INVALID_HANDLE)
	{
		hDeleteOStoreCategoryFromProduct = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_products_categories` WHERE `ostore_products_categories`.`category_id` = ?", error, sizeof(error));
		if (hDeleteOStoreCategoryFromProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	if (hDeleteOStoreCategory == INVALID_HANDLE)
	{
		hDeleteOStoreCategory = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_categories` WHERE `ostore_categories`.`id` = ?", error, sizeof(error));
		if (hDeleteOStoreCategory == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hDeleteOStoreCategoryFromProduct, 0, _:hCategory);
	
	if (!SQL_Execute(hDeleteOStoreCategoryFromProduct))
	{
		PrintSQLErrorToServer(hDeleteOStoreCategoryFromProduct);
		return false;
	}
	
	SQL_BindParamInt(hDeleteOStoreCategory, 0, _:hCategory);
	
	if (!SQL_Execute(hDeleteOStoreCategory))
	{
		PrintSQLErrorToServer(hDeleteOStoreCategory);
		return false;
	}
	
	return true;
}

bool:LinkOStoreProductToCategory(Handle:hProduct, Handle:hCategory)
{
	// 如果产品在分类列表中 移动产品到指定分类 如果不在的话 就在新分类列表创建新关联项目
	decl String:error[255];
	
	if (hFindOStoreProductFromCategory == INVALID_HANDLE)
	{
		hFindOStoreProductFromCategory = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `product_id` FROM `ostore_products_categories` WHERE `product_id` = ?", error, sizeof(error));
		if (hFindOStoreProductFromCategory == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hFindOStoreProductFromCategory, 0, _:hProduct);
	
	if (!SQL_Execute(hFindOStoreProductFromCategory))
	{
		PrintSQLErrorToServer(hFindOStoreProductFromCategory);
		return false;
	}
	
	new bool:isFind = SQL_FetchRow(hFindOStoreProductFromCategory);
	
	if (isFind)
	{
		if (hMoveOStoreProductToCategory == INVALID_HANDLE)
		{
			hMoveOStoreProductToCategory = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_products_categories` SET `category_id` = ? WHERE `ostore_products_categories`.`product_id` = ?", error, sizeof(error));
			if (hMoveOStoreProductToCategory == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamInt(hMoveOStoreProductToCategory, 0, _:hCategory);
		SQL_BindParamInt(hMoveOStoreProductToCategory, 1, _:hProduct);
		
		if (!SQL_Execute(hMoveOStoreProductToCategory))
		{
			PrintSQLErrorToServer(hMoveOStoreProductToCategory);
			return false;
		}
	}
	else
	{
		if (hLinkOStoreProductToCategory == INVALID_HANDLE)
		{
			hLinkOStoreProductToCategory = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_products_categories` (`product_id`, `category_id`) VALUES (?, ?)", error, sizeof(error));
			if (hLinkOStoreProductToCategory == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamInt(hLinkOStoreProductToCategory, 0, _:hProduct);
		SQL_BindParamInt(hLinkOStoreProductToCategory, 1, _:hCategory);
		
		if (!SQL_Execute(hLinkOStoreProductToCategory))
		{
			PrintSQLErrorToServer(hLinkOStoreProductToCategory);
			return false;
		}
	}

	return true;
}

bool:RegOStoreProductType(Handle:hProduct, point, const String:type[]=OSTORE_PRODUCT_TYPE_FOREVER, amount=0, second=0, &Handle:hProductType=INVALID_HANDLE)
{
	if (hFindOStoreProductType == INVALID_HANDLE)
	{
		decl String:error[255];
		hFindOStoreProductType = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id` FROM `ostore_products_type` WHERE `product_id` = ? AND `point` = ? AND `type` = ? AND `amount` = ? AND `second` = ?", error, sizeof(error));
		if (hFindOStoreProductType == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hFindOStoreProductType, 0, _:hProduct);
	SQL_BindParamInt(hFindOStoreProductType, 1, point);
	SQL_BindParamString(hFindOStoreProductType, 2, type, false);
	SQL_BindParamInt(hFindOStoreProductType, 3, amount);
	SQL_BindParamInt(hFindOStoreProductType, 4, second);
	
	if (!SQL_Execute(hFindOStoreProductType))
	{
		PrintSQLErrorToServer(hFindOStoreProductType);
		return false;
	}
	
	if (!SQL_FetchRow(hFindOStoreProductType))
	{
		if (hCreateOStoreProductType == INVALID_HANDLE)
		{
			decl String:error[255];
			hCreateOStoreProductType = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_products_type` (`product_id`, `point`, `type`, `amount`, `second`) VALUES (?, ?, ?, ?, ?)", error, sizeof(error));
			if (hCreateOStoreProductType == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamInt(hCreateOStoreProductType, 0, _:hProduct);
		SQL_BindParamInt(hCreateOStoreProductType, 1, point);
		SQL_BindParamString(hCreateOStoreProductType, 2, type, false);
		SQL_BindParamInt(hCreateOStoreProductType, 3, amount);
		SQL_BindParamInt(hCreateOStoreProductType, 4, second);
		
		if (!SQL_Execute(hCreateOStoreProductType))
		{
			PrintSQLErrorToServer(hCreateOStoreProductType);
			return false;
		}
		
		if (hGetLastInsertId == INVALID_HANDLE)
		{
			decl String:error[255];
			hGetLastInsertId = SQL_PrepareQuery(OStoreGlobalDb, "SELECT LAST_INSERT_ID()", error, sizeof(error));
			if (hGetLastInsertId == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		if (!SQL_Execute(hGetLastInsertId))
		{
			PrintSQLErrorToServer(hGetLastInsertId);
			return false;
		}
		
		if (!SQL_FetchRow(hGetLastInsertId)) return false;
		
		hProductType = Handle:SQL_FetchInt(hGetLastInsertId, 0);
	}
	else
	{
		hProductType = Handle:SQL_FetchInt(hFindOStoreProductType, 0);
	}
	return true;
}

bool:UnRegOStoreProductType(Handle:hProductType)
{
	if (hDeleteOStoreProductType == INVALID_HANDLE)
	{
		decl String:error[255];
		hDeleteOStoreProductType = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_products_type` WHERE `ostore_products_type`.`id` = ?", error, sizeof(error));
		if (hDeleteOStoreProductType == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hDeleteOStoreProductType, 0, _:hProductType);
	
	if (!SQL_Execute(hDeleteOStoreProductType))
	{
		PrintSQLErrorToServer(hDeleteOStoreProductType);
		return false;
	}
	
	return true;
}

bool:ConnectOStoreDb(&Handle:db=INVALID_HANDLE)
{
	decl String:error[255];
	db = SQL_DefConnect(error, sizeof(error));
	if (db == INVALID_HANDLE)
	{
		PrintSQLErrorToServer(db);
		return false;
	}
	
	if (!SQL_SetCharset(OStoreGlobalDb, "utf8"))
	{
		PrintSQLErrorToServer(OStoreGlobalDb);
		return false;
	}
	
	return true;
}

bool:IsOvertime(const String:datetime[])
{
	decl String:currentTimeStr[64];
	FormatTime(currentTimeStr, sizeof(currentTimeStr), "%Y-%m-%d %X");
	
	if (DateTimeComparison(currentTimeStr, datetime) == DATE_TIME_GT)
	{
		return true;
	}
	
	return false;
}

ReadYear(const String:datetime[])
{
	decl String:tmp[255];
	new index = SplitString(datetime, "-", tmp, sizeof(tmp));
	
	if (index == -1) return index;
	
	return StringToInt(tmp);
}

ReadMonth(const String:datetime[])
{
	decl String:tmp[255];
	new newIndex;
	new oldIndex;
	
	for (new i; i < 2; i++)
	{
		newIndex = SplitString(datetime[oldIndex], "-", tmp, sizeof(tmp));
		if (newIndex == -1) return newIndex;
		oldIndex += newIndex;
	}
	
	return StringToInt(tmp);
}
// "1993-07-05 12:55:32"
ReadDay(const String:datetime[])
{
	decl String:tmp[255];
	new newIndex;
	new oldIndex;
	
	for (new i; i < 2; i++)
	{
		newIndex = SplitString(datetime[oldIndex], "-", tmp, sizeof(tmp));
		if (newIndex == -1) return newIndex;
		oldIndex += newIndex;
	}
	
	newIndex = SplitString(datetime[oldIndex], " ", tmp, sizeof(tmp));
	if (newIndex == -1) return newIndex;
	
	return StringToInt(tmp);
}

ReadHour(const String:datetime[])
{
	decl String:tmp[255];
	new newIndex;
	new oldIndex;
	
	newIndex = SplitString(datetime[oldIndex], " ", tmp, sizeof(tmp));
	if (newIndex == -1) return newIndex;
	oldIndex += newIndex;
	
	newIndex = SplitString(datetime[oldIndex], ":", tmp, sizeof(tmp));
	if (newIndex == -1) return newIndex;
	
	return StringToInt(tmp);
}

ReadMinute(const String:datetime[])
{
	decl String:tmp[255];
	new newIndex;
	new oldIndex;
	
	newIndex = SplitString(datetime[oldIndex], " ", tmp, sizeof(tmp));
	if (newIndex == -1) return newIndex;
	oldIndex += newIndex;
	
	for (new i; i < 2; i++)
	{
		newIndex = SplitString(datetime[oldIndex], ":", tmp, sizeof(tmp));
		if (newIndex == -1) return newIndex;
		oldIndex += newIndex;
	}
	
	return StringToInt(tmp);
}

ReadSecond(const String:datetime[])
{
	decl String:tmp[255];
	new newIndex;
	new oldIndex;
	
	newIndex = SplitString(datetime[oldIndex], " ", tmp, sizeof(tmp));
	if (newIndex == -1) return newIndex;
	oldIndex += newIndex;
	
	for (new i; i < 2; i++)
	{
		newIndex = SplitString(datetime[oldIndex], ":", tmp, sizeof(tmp));
		if (newIndex == -1) return newIndex;
		oldIndex += newIndex;
	}
	
	return StringToInt(datetime[oldIndex]);
}

DateTimeComparison(const String:datetime1[], const String:datetime2[])
{
	if (StrEqual(datetime1, datetime2))
	{
		return DATE_TIME_EQUAL;
	}
	
	if (ReadYear(datetime1) != ReadYear(datetime2))
	{
		if (ReadYear(datetime1) > ReadYear(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	} 
	else if (ReadMonth(datetime1) != ReadMonth(datetime2))
	{
		if (ReadMonth(datetime1) > ReadMonth(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	}
	else if (ReadDay(datetime1) != ReadDay(datetime2))
	{
		if (ReadDay(datetime1) > ReadDay(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	}
	else if (ReadHour(datetime1) != ReadHour(datetime2))
	{
		if (ReadHour(datetime1) > ReadHour(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	}
	else if (ReadMinute(datetime1) != ReadMinute(datetime2))
	{
		if (ReadMinute(datetime1) > ReadMinute(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	}
	else if (ReadSecond(datetime1) != ReadSecond(datetime2))
	{
		if (ReadSecond(datetime1) > ReadSecond(datetime2))
		{
			return DATE_TIME_GT;
		}
		else
		{
			return DATE_TIME_LT;
		}
	}
	
	return DATE_TIME_GT;
}

bool:BuyOStoreProduct(client, Handle:hProductType)
{
	new steamId = GetSteamAccountID(client);

	if (hGetOStoreProductTypeInfo == INVALID_HANDLE)
	{
		decl String:error[255];
		hGetOStoreProductTypeInfo = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `product_id`, `point`, `type`, `amount`, `second` FROM `ostore_products_type` WHERE `id` = ?", error, sizeof(error));
		if (hGetOStoreProductTypeInfo == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetOStoreProductTypeInfo, 0, _:hProductType);
	
	if (!SQL_Execute(hGetOStoreProductTypeInfo))
	{
		PrintSQLErrorToServer(hGetOStoreProductTypeInfo);
		return false;
	}
	
	if (!SQL_FetchRow(hGetOStoreProductTypeInfo))
	{
		return false;
	}
	
	new productId = SQL_FetchInt(hGetOStoreProductTypeInfo, 0);
	
	new productPoint = SQL_FetchInt(hGetOStoreProductTypeInfo, 1);
	
	new accountPoint;
	GetOStoreAccountPoint(client, accountPoint);
	
	if (accountPoint < productPoint)
	{
		// Point 不足所以购买失败
		PrintToChat(client, "[OStore] 你的 Point 数量不足以购买此产品")
		return true;
	}
	
	decl String:productType[OSTORE_TYPE_MAX_LENGTH];
	SQL_FetchString(hGetOStoreProductTypeInfo, 2, productType, sizeof(productType));
	new productAmount = SQL_FetchInt(hGetOStoreProductTypeInfo, 3);
	new productSecond = SQL_FetchInt(hGetOStoreProductTypeInfo, 4);

	if (hGetOStoreAccountProductInfo == INVALID_HANDLE)
	{
		decl String:error[255];
		hGetOStoreAccountProductInfo = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `type`, `amount`, `validity` FROM `ostore_accounts_products` WHERE `account_id` = ? AND `product_id` = ?", error, sizeof(error));
		if (hGetOStoreAccountProductInfo == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetOStoreAccountProductInfo, 0, steamId);
	SQL_BindParamInt(hGetOStoreAccountProductInfo, 1, productId);
	
	if (!SQL_Execute(hGetOStoreAccountProductInfo))
	{
		PrintSQLErrorToServer(hGetOStoreAccountProductInfo);
		return false;
	}
	
	// 如果账户不存在这种产品则创建，否则进行产品合并
	if (!SQL_FetchRow(hGetOStoreAccountProductInfo))
	{	
		if (hCreateOStoreAccountProduct == INVALID_HANDLE)
		{
			decl String:error[255];
			hCreateOStoreAccountProduct = SQL_PrepareQuery(OStoreGlobalDb, "INSERT INTO `ostore_accounts_products` (`account_id`, `product_id`, `type`, `amount`, `validity`) VALUES (?, ?, ?, ?, ADDDATE(CURRENT_TIMESTAMP(), INTERVAL ? SECOND))", error, sizeof(error));
			if (hCreateOStoreAccountProduct == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		SQL_BindParamString(hCreateOStoreAccountProduct, 2, productType, false);
		
		if (StrEqual(productType, OSTORE_PRODUCT_TYPE_FOREVER))
		{
			SQL_BindParamInt(hCreateOStoreAccountProduct, 0, steamId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 1, productId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 3, 0);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 4, 0);
			
			if (!SQL_Execute(hCreateOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hCreateOStoreAccountProduct);
				return false;
			}
			
			PrintToChat(client, "[OStore] 产品购买成功，你可以永久使用此产品了");
		}
		else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_AMOUNT))
		{
			SQL_BindParamInt(hCreateOStoreAccountProduct, 0, steamId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 1, productId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 3, productAmount);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 4, 0);
				
			if (!SQL_Execute(hCreateOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hCreateOStoreAccountProduct);
				return false;
			}
			
			PrintToChat(client, "[OStore] 产品购买成功，你可以使用此产品 %d 次了", productAmount);
		}
		else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_VALIDITY))
		{
			SQL_BindParamInt(hCreateOStoreAccountProduct, 0, steamId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 1, productId);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 3, 0);
			SQL_BindParamInt(hCreateOStoreAccountProduct, 4, productSecond);
			
			if (!SQL_Execute(hCreateOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hCreateOStoreAccountProduct);
				return false;
			}
			
			PrintToChat(client, "[OStore] 产品购买成功，你可以使用此产品 %d 秒了", productSecond);
		}

	}
	else
	{
		decl String:accountProductType[OSTORE_TYPE_MAX_LENGTH];
		new accountProductAmount;
		decl String:accountProductValidity[OSTORE_VALIDITY_MAX_LENGTH];
		
		SQL_FetchString(hGetOStoreAccountProductInfo, 0, accountProductType, sizeof(accountProductType));
		accountProductAmount = SQL_FetchInt(hGetOStoreAccountProductInfo, 1);
		SQL_FetchString(hGetOStoreAccountProductInfo, 2, accountProductValidity, sizeof(accountProductValidity));
		
		if (hUpdateOStoreAccountProduct == INVALID_HANDLE)
		{
			decl String:error[255];
			hUpdateOStoreAccountProduct = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_accounts_products` SET `amount` = `amount` + ?, `validity` = ADDDATE(`validity`, INTERVAL ? SECOND) WHERE `ostore_accounts_products`.`account_id` = ? AND `ostore_accounts_products`.`product_id` = ?", error, sizeof(error));
			if (hUpdateOStoreAccountProduct == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		if (hDeleteOStoreAccountProduct == INVALID_HANDLE)
		{
			decl String:error[255];
			hDeleteOStoreAccountProduct = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_accounts_products` WHERE `ostore_accounts_products`.`account_id` = ? AND `ostore_accounts_products`.`product_id` = ?", error, sizeof(error));
			if (hDeleteOStoreAccountProduct == INVALID_HANDLE)
			{
				PrintToServer("[OStore]SQL Error: %s", error);
				return false;
			}
		}
		
		if (!StrEqual(accountProductType, productType))
		{
			if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_FOREVER))
			{
				PrintToChat(client, "[OStore] 你当前已经拥有此产品的永久使用权限，无需再次购买了");
			}
			else if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_AMOUNT))
			{
				PrintToChat(client, "[OStore] 你当前拥有此产品的使用次数，请使用完再次购买 (剩余 %d 次)", accountProductAmount);
			}
			else if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_VALIDITY))
			{
				// 检测商品是否过时 过时删除创建新项目 否则进行产品合并
				if (IsOvertime(accountProductValidity))
				{
					// 删除
					SQL_BindParamInt(hDeleteOStoreAccountProduct, 0, steamId);
					SQL_BindParamInt(hDeleteOStoreAccountProduct, 1, productId);
					
					if (!SQL_Execute(hDeleteOStoreAccountProduct))
					{
						PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
						return false;
					}
					
					BuyOStoreProduct(client, hProductType);
					return true;
				}
				
				PrintToChat(client, "[OStore] 你当前拥有此产品并且还在可使用的时效内，请过期后再次购买 (过期时间 %d 年 %d 月 %d 日 - %d 时 %d 分 %d 秒)", ReadYear(accountProductValidity), ReadMonth(accountProductValidity), ReadDay(accountProductValidity), ReadHour(accountProductValidity), ReadMinute(accountProductValidity), ReadSecond(accountProductValidity));
			}
			
			return true;
		}
		
		
		if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_FOREVER))
		{
			// 已经拥有永久的商品无需再次购买
			PrintToChat(client, "[OStore] 你当前已经拥有此产品的永久使用权限，无需再次购买了");
		}
		else if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_AMOUNT))
		{
			// 检测商品使用数量 为零删除 创建新项目 否则进行产品合并
			// 进行产品更新
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 0, productAmount);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 1, 0);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 2, steamId);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 3, productId);
			
			if (!SQL_Execute(hUpdateOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
				return false;
			}
			
			PrintToChat(client, "[OStore] 产品购买成功，使用次数 +%d 次", productAmount);
		}
		else if (StrEqual(accountProductType, OSTORE_PRODUCT_TYPE_VALIDITY))
		{
			if (IsOvertime(accountProductValidity))
			{
				// 删除
				SQL_BindParamInt(hDeleteOStoreAccountProduct, 0, steamId);
				SQL_BindParamInt(hDeleteOStoreAccountProduct, 1, productId);
				
				if (!SQL_Execute(hDeleteOStoreAccountProduct))
				{
					PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
					return false;
				}
				
				BuyOStoreProduct(client, hProductType);
				return true;
			}
			
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 0, 0);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 1, productSecond);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 2, steamId);
			SQL_BindParamInt(hUpdateOStoreAccountProduct, 3, productId);
			
			if (!SQL_Execute(hUpdateOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
				return false;
			}
			
			PrintToChat(client, "[OStore] 产品购买成功，使用期增加了 %d 秒", productSecond);
		}
	}
	
	SetOStoreAccountPoint(client, accountPoint - productPoint); // 扣除点数
	PrintToChat(client, "[OStore] 你消费了 %d Point 当前剩余 %d Point", productPoint, accountPoint - productPoint);
	// 我特么写的这是个什么东西 (/▽＼=)
	return true;
}

bool:UseOStoreProduct(client, Handle:hProduct)
{
	new steamId = GetSteamAccountID(client);
	
	if (hGetOStoreAccountProductInfo2 == INVALID_HANDLE)
	{
		decl String:error[255];
		
		hGetOStoreAccountProductInfo2 = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `type`, `amount`, `validity` FROM `ostore_accounts_products` WHERE `account_id` = ? AND `product_id` = ?", error, sizeof(error));
		if (hGetOStoreAccountProductInfo2 == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetOStoreAccountProductInfo2, 0, steamId);
	SQL_BindParamInt(hGetOStoreAccountProductInfo2, 1, _:hProduct);
	
	if (hDeleteOStoreAccountProduct == INVALID_HANDLE)
	{
		decl String:error[255];
		
		hDeleteOStoreAccountProduct = SQL_PrepareQuery(OStoreGlobalDb, "DELETE FROM `ostore_accounts_products` WHERE `ostore_accounts_products`.`account_id` = ? AND `ostore_accounts_products`.`product_id` = ?", error, sizeof(error));
		if (hDeleteOStoreAccountProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hDeleteOStoreAccountProduct, 0, steamId);
	SQL_BindParamInt(hDeleteOStoreAccountProduct, 1, _:hProduct);
	
	decl String:productType[OSTORE_TYPE_MAX_LENGTH];
	decl String:productValidity[OSTORE_VALIDITY_MAX_LENGTH];
	new productAmount;
	
	if (!SQL_Execute(hGetOStoreAccountProductInfo2))
	{
		PrintSQLErrorToServer(hGetOStoreAccountProductInfo2);
		return false;
	}
	
	if (!SQL_FetchRow(hGetOStoreAccountProductInfo2))
	{
		return false;
	}
	
	SQL_FetchString(hGetOStoreAccountProductInfo2, 0, productType, sizeof(productType));
	productAmount = SQL_FetchInt(hGetOStoreAccountProductInfo2, 1);
	SQL_FetchString(hGetOStoreAccountProductInfo2, 2, productValidity, sizeof(productValidity));
	
	if (StrEqual(productType, OSTORE_PRODUCT_TYPE_FOREVER))
	{
		return true;
	}
	else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_AMOUNT))
	{
		// 检测商品是否过时 过时删除创建新项目
		productAmount--;
		if (productAmount == 0)
		{
			// 删除
			if (!SQL_Execute(hDeleteOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
				return false;
			}
			return true;
		}
		else
		{
			if (hDecOStoreAccountProductAmount == INVALID_HANDLE)
			{
				decl String:error[255];
				hDecOStoreAccountProductAmount = SQL_PrepareQuery(OStoreGlobalDb, "UPDATE `ostore_accounts_products` SET `amount` = `amount` - 1 WHERE `ostore_accounts_products`.`account_id` = ? AND `ostore_accounts_products`.`product_id` = ?", error, sizeof(error));
				if (hDecOStoreAccountProductAmount == INVALID_HANDLE)
				{
					PrintToServer("[OStore]SQL Error: %s", error);
					return false;
				}
			}
			
			SQL_BindParamInt(hDecOStoreAccountProductAmount, 0, steamId);
			SQL_BindParamInt(hDecOStoreAccountProductAmount, 1, _:hProduct);
			
			if (!SQL_Execute(hDecOStoreAccountProductAmount))
			{
				PrintSQLErrorToServer(hDecOStoreAccountProductAmount);
				return false;
			}
			
			return true;
		}
		
	}
	else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_VALIDITY))
	{
		// 检测商品是否过时
		if (IsOvertime(productValidity))
		{
			// 删除
			if (!SQL_Execute(hDeleteOStoreAccountProduct))
			{
				PrintSQLErrorToServer(hUpdateOStoreAccountProduct);
				return false;
			}
			return false;
		}
		else
		{
			return true;
		}
	}
	
	return false;
}

bool:BuildOStoreCategoryMenu(&Handle:menu=INVALID_HANDLE)
{	
	if (hGetAllOStoreCategory == INVALID_HANDLE)
	{
		decl String:error[255];
		hGetAllOStoreCategory = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id`, `name` FROM `ostore_categories`", error, sizeof(error));
		if (hGetAllOStoreCategory == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	if (!SQL_Execute(hGetAllOStoreCategory))
	{
		PrintSQLErrorToServer(hGetAllOStoreCategory);
		return false;
	}

	menu = CreateMenu(MenuOStoreCategory);
	SetMenuTitle(menu, "商品 > 类别\n ");
	
	while (SQL_FetchRow(hGetAllOStoreCategory))
	{
		decl String:categoryId[20];
		IntToString(SQL_FetchInt(hGetAllOStoreCategory, 0), categoryId, sizeof(categoryId));
		
		decl String:categoryName[OSTORE_NAME_MAX_LENGTH];
		SQL_FetchString(hGetAllOStoreCategory, 1, categoryName, sizeof(categoryName));
		
		AddMenuItem(menu, categoryId, categoryName);
	}
	
	return true;
}

bool:BuildOStoreCategoryProductMenu(Handle:hCategory, &Handle:menu=INVALID_HANDLE)
{
	decl String:error[255];
	
	if (hGetCategoryInfo == INVALID_HANDLE)
	{
		hGetCategoryInfo = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `name`, `detail` FROM `ostore_categories` WHERE `id` = ?", error, sizeof(error));
		if (hGetCategoryInfo == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetCategoryInfo, 0, _:hCategory);
	
	if (!SQL_Execute(hGetCategoryInfo))
	{
		PrintSQLErrorToServer(hGetCategoryInfo);
		return false;
	}
	
	decl String:categoryName[OSTORE_NAME_MAX_LENGTH];
	decl String:categoryDetail[OSTORE_DETAIL_MAX_LENGTH];
	
	if (SQL_FetchRow(hGetCategoryInfo))
	{
		SQL_FetchString(hGetCategoryInfo, 0, categoryName, sizeof(categoryName));
		SQL_FetchString(hGetCategoryInfo, 1, categoryDetail, sizeof(categoryDetail));
	}
	else
	{
		return false;
	}
	
	if (hGetAllOStoreCategoryProduct == INVALID_HANDLE)
	{
		hGetAllOStoreCategoryProduct = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `product_id` FROM `ostore_products_categories` WHERE `category_id` = ?", error, sizeof(error));
		if (hGetAllOStoreCategoryProduct == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetAllOStoreCategoryProduct, 0, _:hCategory);
	
	if (!SQL_Execute(hGetAllOStoreCategoryProduct))
	{
		PrintSQLErrorToServer(hGetAllOStoreCategoryProduct);
		return false;
	}
	
	if (hGetProductName == INVALID_HANDLE)
	{
		hGetProductName = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `name` FROM `ostore_products` WHERE `id` = ?", error, sizeof(error));
		if (hGetProductName == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	menu = CreateMenu(MenuOStoreCategoryProduct);
	decl String:menuTitle[OSTORE_NAME_MAX_LENGTH + OSTORE_DETAIL_MAX_LENGTH + 64];
	Format(menuTitle, sizeof(menuTitle), "商品 > 类别 > %s \n简介: %s\n ", categoryName, categoryDetail);
	SetMenuTitle(menu, menuTitle);
	
	if (SQL_GetRowCount(hGetAllOStoreCategory) == 0)
	{
		// 当前分类没有产品
		return false;
	}
	
	while (SQL_FetchRow(hGetAllOStoreCategoryProduct))
	{
		new productId = SQL_FetchInt(hGetAllOStoreCategoryProduct, 0);
		
		SQL_BindParamInt(hGetProductName, 0, productId);
		
		if (!SQL_Execute(hGetProductName))
		{
			PrintSQLErrorToServer(hGetProductName);
			return false;
		}
		
		if (SQL_FetchRow(hGetProductName))
		{
			decl String:productName[OSTORE_NAME_MAX_LENGTH];
			decl String:productIdStr[20];
			IntToString(productId, productIdStr, sizeof(productIdStr));
			
			SQL_FetchString(hGetProductName, 0, productName, sizeof(productName));
			
			AddMenuItem(menu, productIdStr, productName);
		}
	}
	
	return true;
}

bool:BuildOStoreProdcutTypeMenu(Handle:hProduct, &Handle:menu=INVALID_HANDLE)
{
	decl String:error[255];
	
	if (hGetOStoreProductInfo == INVALID_HANDLE)
	{
		hGetOStoreProductInfo = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `name`, `detail` FROM `ostore_products` WHERE `id` = ?", error, sizeof(error));
		if (hGetOStoreProductInfo == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetOStoreProductInfo, 0, _:hProduct);
	
	if (!SQL_Execute(hGetOStoreProductInfo))
	{
		PrintSQLErrorToServer(hGetOStoreProductInfo);
		return false;
	}
	
	decl String:productName[OSTORE_NAME_MAX_LENGTH];
	decl String:productDetail[OSTORE_DETAIL_MAX_LENGTH];
	
	if (SQL_FetchRow(hGetOStoreProductInfo))
	{
		SQL_FetchString(hGetOStoreProductInfo, 0, productName, sizeof(productName));
		SQL_FetchString(hGetOStoreProductInfo, 1, productDetail, sizeof(productDetail));
	}
	else
	{
		return false;
	}

	if (hGetAllOStoreProductType == INVALID_HANDLE)
	{
		hGetAllOStoreProductType = SQL_PrepareQuery(OStoreGlobalDb, "SELECT `id`, `point`, `type`, `amount`, `second` FROM `ostore_products_type` WHERE `product_id` = ?", error, sizeof(error));
		if (hGetAllOStoreProductType == INVALID_HANDLE)
		{
			PrintToServer("[OStore]SQL Error: %s", error);
			return false;
		}
	}
	
	SQL_BindParamInt(hGetAllOStoreProductType, 0, _:hProduct);
	
	if (!SQL_Execute(hGetAllOStoreProductType))
	{
		PrintSQLErrorToServer(hGetAllOStoreProductType);
		return false;
	}
	
	menu = CreateMenu(MenuOStoreProductType); // ***
	decl String:menuTitle[OSTORE_NAME_MAX_LENGTH + OSTORE_DETAIL_MAX_LENGTH + 64];
	Format(menuTitle, sizeof(menuTitle), "商品 > 类别 > 产品 > %s \n简介: %s\n ", productName, productDetail);
	SetMenuTitle(menu, menuTitle);
	
	while (SQL_FetchRow(hGetAllOStoreProductType))
	{
		new productTypeId;
		new productTypePoint;
		decl String:productType[OSTORE_TYPE_MAX_LENGTH];
		new productTypeAmount;
		new productTypeSecond;
	
		productTypeId = SQL_FetchInt(hGetAllOStoreProductType, 0);
		productTypePoint = SQL_FetchInt(hGetAllOStoreProductType, 1);
		SQL_FetchString(hGetAllOStoreProductType, 2, productType, sizeof(productType));
		productTypeAmount = SQL_FetchInt(hGetAllOStoreProductType, 3);
		productTypeSecond = SQL_FetchInt(hGetAllOStoreProductType, 4);
		
		decl String:productTypeIdStr[20];
		IntToString(productTypeId, productTypeIdStr, sizeof(productTypeIdStr));
		
		decl String:productTypeDisItem[255];
		
		if (StrEqual(productType, OSTORE_PRODUCT_TYPE_FOREVER))
		{
			Format(productTypeDisItem, sizeof(productTypeDisItem), "%d Point - 永久", productTypePoint);
		}
		else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_AMOUNT))
		{
			Format(productTypeDisItem, sizeof(productTypeDisItem), "%d Point - 使用 %d 次", productTypePoint, productTypeAmount);
		}
		else if (StrEqual(productType, OSTORE_PRODUCT_TYPE_VALIDITY))
		{
			Format(productTypeDisItem, sizeof(productTypeDisItem), "%d Point - 使用时长 %d 秒", productTypePoint, productTypeSecond);
		}
		
		AddMenuItem(menu, productTypeIdStr, productTypeDisItem);
	}
	
	return true;
}

public OnPluginStart()
{
	ConnectOStoreDb(OStoreGlobalDb);
	RegConsoleCmd("ostore", Command_OStore);
	RegConsoleCmd("ostore_point", Command_ShowPoint);
}

public OnPluginEnd()
{
	PrintToServer("[OStore] Unloaded.");
}

public OnClientPutInServer(client)
{
	new bool:isExist;
	IsOStoreAccountExist(client, isExist);
	
	if (!isExist)
	{
		CreateOStoreAccount(client);
		PrintToChat(client, "[OStore] 账户数据创建完成!");
	}
	else
	{
		PrintToChat(client, "[OStore] 账户数据载入完成!")
	}
}

public Action:Command_ShowPoint(client, args)
{
	new point;
	
	if (GetOStoreAccountPoint(client, point))
	{
		PrintToChat(client, "你当前有 Point: %d", point);
	}
	
	return Plugin_Handled;
}

public Action:Command_OStore(client, args)
{
	new Handle:menu = INVALID_HANDLE;
	if (BuildOStoreCategoryMenu(menu))
	{
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
	}
}

public MenuOStoreCategory(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new client = param1;
		new itemIndex = param2;

		decl String:categoryIdStr[20];
		decl String:categoryName[OSTORE_NAME_MAX_LENGTH];
		new bool:found = GetMenuItem(menu, itemIndex, categoryIdStr, sizeof(categoryIdStr), _, categoryName, sizeof(categoryName));
		
		if (found)
		{
			new categoryId = StringToInt(categoryIdStr);
			ClientSeletctPrevMenuIndex[client] = categoryId;
			PrintToChat(client, "[OStore] 你选择了分类 %s (%d)", categoryName, categoryId);
			new Handle:productMenu = INVALID_HANDLE;
			if (BuildOStoreCategoryProductMenu(Handle:categoryId, productMenu))
			{
				DisplayMenu(productMenu, client, MENU_TIME_FOREVER);
			}
			else
			{
				PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
			}
		}
		else
		{
			PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
		}
	}
	else if (action == MenuAction_Cancel)
	{
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuOStoreCategoryProduct(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new client = param1;
		new itemIndex = param2;

		decl String:productIdStr[20];
		decl String:productName[OSTORE_NAME_MAX_LENGTH];
		new bool:found = GetMenuItem(menu, itemIndex, productIdStr, sizeof(productIdStr), _, productName, sizeof(productName));
		
		if (found)
		{
			new productId = StringToInt(productIdStr);
			PrintToChat(client, "[OStore] 你选择了产品 %s (%d)", productName, productId);
			new Handle:productTypeMenu = INVALID_HANDLE;
			if (BuildOStoreProdcutTypeMenu(Handle:productId, productTypeMenu))
			{
				DisplayMenu(productTypeMenu, client, MENU_TIME_FOREVER);
			}
			else
			{
				PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
			}
		}
		else
		{
			PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
		}
	}
	else if (action == MenuAction_Cancel)
	{
		new client = param1;
		
		new Handle:categoryMenu = INVALID_HANDLE;
		if (BuildOStoreCategoryMenu(categoryMenu))
		{
			DisplayMenu(categoryMenu, client, MENU_TIME_FOREVER);
		}
		else
		{
			PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public MenuOStoreProductType(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		new client = param1;
		new itemIndex = param2;

		decl String:productTypeIdStr[20];
		decl String:productTypeName[OSTORE_NAME_MAX_LENGTH];
		new bool:found = GetMenuItem(menu, itemIndex, productTypeIdStr, sizeof(productTypeIdStr), _, productTypeName, sizeof(productTypeName));
		
		if (found)
		{
			new productTypeId = StringToInt(productTypeIdStr);
			PrintToChat(client, "[OStore] 你选择了产品类型 %s (%d)", productTypeName, productTypeId);
			BuyOStoreProduct(client, Handle:productTypeId);
		}
		else
		{
			PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
		}
	}
	else if (action == MenuAction_Cancel)
	{
		new client = param1;
		
		new Handle:productMenu = INVALID_HANDLE;
		if (BuildOStoreCategoryProductMenu(Handle:ClientSeletctPrevMenuIndex[client], productMenu))
		{
			DisplayMenu(productMenu, client, MENU_TIME_FOREVER);
		}
		else
		{
			PrintToChat(client, "[OStore] (ˉ▽ˉ；)... 好像出错了");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
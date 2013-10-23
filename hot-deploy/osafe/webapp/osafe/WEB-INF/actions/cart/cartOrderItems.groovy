package common;

import java.math.BigDecimal;
import java.util.List;

import org.ofbiz.base.util.UtilValidate;

import javolution.util.FastList;
import javolution.util.FastMap;
import org.ofbiz.entity.GenericValue;
import org.ofbiz.entity.util.EntityUtil;
import org.ofbiz.product.product.ProductContentWrapper;
import org.ofbiz.product.product.ProductWorker;
import com.osafe.util.Util;
import org.ofbiz.base.util.UtilMisc;
import com.osafe.services.CatalogUrlServlet;
import org.ofbiz.base.util.StringUtil;
import org.ofbiz.entity.Delegator;
import com.osafe.services.InventoryServices;
import org.ofbiz.order.shoppingcart.ShoppingCart;
import org.ofbiz.order.shoppingcart.ShoppingCartItem;
import org.apache.commons.lang.StringUtils;
import org.ofbiz.base.util.Debug;
import org.ofbiz.product.catalog.CatalogWorker;


ShoppingCartItem cartLine = request.getAttribute("cartLine");
ShoppingCart shoppingCart = session.getAttribute("shoppingCart");
context.shoppingCart=shoppingCart;
currentCatalogId = CatalogWorker.getCurrentCatalogId(request);
autoUserLogin = request.getSession().getAttribute("autoUserLogin");
webSiteId = CatalogWorker.getWebSiteId(request);
virtualProduct="";
recurrenceItem = "N";
recurrenceSavePercent = null;
offerPrice = "";
stockInfo = "";
quantity = 0;
showGiftMessageLink = false;

//Get currency
currencyUom = Util.getProductStoreParm(request,"CURRENCY_UOM_DEFAULT");
if(UtilValidate.isEmpty(currencyUom))
{
	currencyUom = shoppingCart.getCurrency();
}

cartLineIndex = shoppingCart.getItemIndex(cartLine);
product = cartLine.getProduct();
urlProductId = cartLine.getProductId();
productId = cartLine.getProductId();
productCategoryId = cartLine.getProductCategoryId();
if(UtilValidate.isEmpty(productCategoryId))
{
	productCategoryId = product.primaryProductCategoryId;
}
if(UtilValidate.isEmpty(productCategoryId))
{
	productCategoryMemberList = product.getRelatedCache("ProductCategoryMember");
	productCategoryMemberList = EntityUtil.filterByDate(productCategoryMemberList,true);
	productCategoryMemberList = EntityUtil.orderBy(productCategoryMemberList, UtilMisc.toList('sequenceNum'));
	if(UtilValidate.isNotEmpty(productCategoryMemberList))
	{
		productCategoryMember = EntityUtil.getFirst(productCategoryMemberList);
		productCategoryId = productCategoryMember.productCategoryId;
	}
}
if(UtilValidate.isNotEmpty(product.isVariant) && "Y".equals(product.isVariant))
{
	virtualProduct = ProductWorker.getParentProduct(cartLine.getProductId(), delegator);
	urlProductId = virtualProduct.productId;
	if(UtilValidate.isEmpty(productCategoryId))
	{
		productCategoryMemberList = virtualProduct.getRelatedCache("ProductCategoryMember");
		productCategoryMemberList = EntityUtil.filterByDate(productCategoryMemberList,true);
		productCategoryMemberList = EntityUtil.orderBy(productCategoryMemberList, UtilMisc.toList('sequenceNum'));
		if(UtilValidate.isNotEmpty(productCategoryMemberList))
		{
			productCategoryMember = EntityUtil.getFirst(productCategoryMemberList);
			productCategoryId = productCategoryMember.productCategoryId;
		}
	}
}

//Product Image URL
productImageUrl = ProductContentWrapper.getProductContentAsText(cartLine.getProduct(), "SMALL_IMAGE_URL", locale, dispatcher);
if(UtilValidate.isEmpty(productImageUrl) && UtilValidate.isNotEmpty(virtualProduct))
{
	productImageUrl = ProductContentWrapper.getProductContentAsText(virtualProduct, "SMALL_IMAGE_URL", locale, dispatcher);
}
//If the string is a literal "null" make it an "" empty string then all normal logic can stay the same
if(UtilValidate.isNotEmpty(productImageUrl) && "null".equals(productImageUrl))
{
	productImageUrl = "";
}
//Product Alt Image URL
productImageAltUrl = ProductContentWrapper.getProductContentAsText(cartLine.getProduct(), "SMALL_IMAGE_ALT_URL", locale, dispatcher);
if(UtilValidate.isEmpty(productImageAltUrl) && UtilValidate.isNotEmpty(virtualProduct))
{
	productImageAltUrl = ProductContentWrapper.getProductContentAsText(virtualProduct, "SMALL_IMAGE_ALT_URL", locale, dispatcher);
}
//If the string is a literal "null" make it an "" empty string then all normal logic can stay the same
if(UtilValidate.isNotEmpty(productImageAltUrl) && "null".equals(productImageAltUrl))
{
	productImageAltUrl = "";
}

//Product Name
productName = ProductContentWrapper.getProductContentAsText(cartLine.getProduct(), "PRODUCT_NAME", locale, dispatcher);
if(UtilValidate.isEmpty(productName) && UtilValidate.isNotEmpty(virtualProduct))
{
	productName = ProductContentWrapper.getProductContentAsText(virtualProduct, "PRODUCT_NAME", locale, dispatcher);
}

price = cartLine.getBasePrice();
displayPrice = cartLine.getDisplayPrice();

//If the item was added to the Shopping Cart as a Recurrence Item
//The Base and Display Price in the cart is changed to match the Recurrence Price.
//To display the Recurrence Savings the system is calling calculate product price here to get back the original Default price.
recurrencePrice = cartLine.getRecurringDisplayPrice();
if (UtilValidate.isNotEmpty(cartLine.getShoppingListId()) && "SLT_AUTO_REODR".equals(cartLine.getShoppingListId()))
{
        priceContext = [product : cartLine.getProduct(), prodCatalogId : currentCatalogId,
                    currencyUomId : shoppingCart.getCurrency(), autoUserLogin : autoUserLogin];
        priceContext.webSiteId = webSiteId;
        priceContext.productStoreId = productStoreId;
        priceContext.checkIncludeVat = "Y";
        priceContext.agreementId = shoppingCart.getAgreementId();
        priceContext.productPricePurposeId = "PURCHASE";
        priceContext.partyId = shoppingCart.getPartyId();  
        productPriceMap = dispatcher.runSync("calculateProductPrice", priceContext);
		productPrice = productPriceMap.price;
		recurrenceSavePercent = (productPrice - recurrencePrice) / productPrice;
    	recurrenceItem = "Y";
	
}

cartItemAdjustment = cartLine.getOtherAdjustments();
if (UtilValidate.isNotEmpty(cartItemAdjustment) && cartItemAdjustment < 0)
{
	offerPrice = cartLine.getDisplayPrice() + (cartItemAdjustment/cartLine.getQuantity());
}
if (cartLine.getIsPromo() || (shoppingCart.getOrderType() == "SALES_ORDER" && !security.hasEntityPermission("ORDERMGR", "_SALES_PRICEMOD", session)))
{
	price= cartLine.getDisplayPrice();
}
else 
{ 
	if (cartLine.getSelectedAmount() > 0)
	{
		price = cartLine.getBasePrice() / cartLine.getSelectedAmount();
	}
	else
	{
		price = cartLine.getBasePrice();
	}
}

inStock = true;
inventoryLevelMap = InventoryServices.getProductInventoryLevel(urlProductId, request);
inventoryLevel = inventoryLevelMap.get("inventoryLevel");
inventoryInStockFrom = inventoryLevelMap.get("inventoryLevelInStockFrom");
inventoryOutOfStockTo = inventoryLevelMap.get("inventoryLevelOutOfStockTo");
if (inventoryLevel <= inventoryOutOfStockTo)
{
	stockInfo = uiLabelMap.OutOfStockLabel;
	inStock = false;
}
else
{
	if (inventoryLevel >= inventoryInStockFrom)
	{
		stockInfo = uiLabelMap.InStockLabel;
	}
	else
	{
		stockInfo = uiLabelMap.LowStockLabel;
	}
}

if(UtilValidate.isNotEmpty(cartLine))
{
	quantity = cartLine.getQuantity();
}

checkoutGiftMessage = Util.isProductStoreParmTrue(request,"CHECKOUT_GIFT_MESSAGE");
pdpGiftMessageAttributeValue = "";
if(UtilValidate.isNotEmpty(product))
{
	pdpGiftMessageAttribute = delegator.findOne("ProductAttribute", UtilMisc.toMap("productId",productId,"attrName","CHECKOUT_GIFT_MESSAGE"), true);
	if(UtilValidate.isNotEmpty(pdpGiftMessageAttribute))
	{
		pdpGiftMessageAttributeValue = pdpGiftMessageAttribute.attrValue;
	}
}
//if sys param is false then do not show gift message link
if((UtilValidate.isNotEmpty(checkoutGiftMessage) && checkoutGiftMessage == true) && (UtilValidate.isNotEmpty(pdpGiftMessageAttributeValue) && !("FALSE".equals(pdpGiftMessageAttributeValue))))
{
	showGiftMessageLink = true;
}
else if((UtilValidate.isNotEmpty(checkoutGiftMessage) && checkoutGiftMessage == true) && UtilValidate.isEmpty(pdpGiftMessageAttributeValue))
{
	showGiftMessageLink = true;
}
else if(UtilValidate.isNotEmpty(pdpGiftMessageAttributeValue) && ("TRUE".equals(pdpGiftMessageAttributeValue)))
{
	showGiftMessageLink = true;
}
else
{
	showGiftMessageLink = false;
}

Map cartAttrMap = cartLine.getOrderItemAttributes();
int counter = 1;
int quantityWithGiftMess = 0;
showEditLabel = "N";
if(showGiftMessageLink)
{
	//flag indicating which giftmessage label to display
	if(UtilValidate.isNotEmpty(cartAttrMap))
	{
		while(counter < (quantity + 1))
		{
			suffix = counter;
			if(counter< 10)
			{
				suffix = "0" + counter;
			}
			if(UtilValidate.isNotEmpty(cartAttrMap.get("GIFT_MSG_FROM_" + suffix)))
			{
				showEditLabel = "Y";
				break;
			}
			if(UtilValidate.isNotEmpty(cartAttrMap.get("GIFT_MSG_TO_" + suffix)))
			{
				showEditLabel = "Y";
				break;
			}
			if(UtilValidate.isNotEmpty(cartAttrMap.get("GIFT_MSG_TEXT_" + suffix)))
			{
				showEditLabel = "Y";
				break;
			}
			counter = counter + 1;
		}
	}
}

//BUILD CONTEXT MAP FOR PRODUCT_FEATURE_TYPE_ID and DESCRIPTION(EITHER FROM PRODUCT_FEATURE_GROUP OR PRODUCT_FEATURE_TYPE)
Map productFeatureTypesMap = FastMap.newInstance();
productFeatureTypesList = delegator.findList("ProductFeatureType", null, null, null, null, true);

//get the whole list of ProductFeatureGroup and ProductFeatureGroupAndAppl
productFeatureGroupList = delegator.findList("ProductFeatureGroup", null, null, null, null, true);
productFeatureGroupAndApplList = delegator.findList("ProductFeatureGroupAndAppl", null, null, null, null, true);
productFeatureGroupAndApplList = EntityUtil.filterByDate(productFeatureGroupAndApplList);

if(UtilValidate.isNotEmpty(productFeatureTypesList))
{
	for (GenericValue productFeatureType : productFeatureTypesList)
	{
		//filter the ProductFeatureGroupAndAppl list based on productFeatureTypeId to get the ProductFeatureGroupId
		productFeatureGroupAndAppls = EntityUtil.filterByAnd(productFeatureGroupAndApplList, UtilMisc.toMap("productFeatureTypeId", productFeatureType.productFeatureTypeId));
		description = "";
		if(UtilValidate.isNotEmpty(productFeatureGroupAndAppls))
		{
			productFeatureGroupAndAppl = EntityUtil.getFirst(productFeatureGroupAndAppls);
			productFeatureGroups = EntityUtil.filterByAnd(productFeatureGroupList, UtilMisc.toMap("productFeatureGroupId", productFeatureGroupAndAppl.productFeatureGroupId));
			productFeatureGroup = EntityUtil.getFirst(productFeatureGroups);
			description = productFeatureGroup.description;
		}
		else
		{
			description = productFeatureType.description;
		}
		productFeatureTypesMap.put(productFeatureType.productFeatureTypeId,description);
	}
	
}

//product features : STANDARD FEATURES 
productFeatureAndAppls = delegator.findByAndCache("ProductFeatureAndAppl", UtilMisc.toMap("productId", productId, "productFeatureApplTypeId", "STANDARD_FEATURE"), UtilMisc.toList("sequenceNum"));
productFeatureAndAppls = EntityUtil.filterByDate(productFeatureAndAppls,true);
productFeatureAndAppls = EntityUtil.orderBy(productFeatureAndAppls,UtilMisc.toList('sequenceNum'));

productFriendlyUrl = CatalogUrlServlet.makeCatalogFriendlyUrl(request,'eCommerceProductDetail?productId='+urlProductId+'&productCategoryId='+productCategoryId+'');



context.productImageUrl = productImageUrl;
context.productImageAltUrl = productImageAltUrl;
context.IMG_SIZE_CART_H = Util.getProductStoreParm(request,"IMG_SIZE_CART_H");
context.IMG_SIZE_CART_W = Util.getProductStoreParm(request,"IMG_SIZE_CART_W");
context.productFriendlyUrl = productFriendlyUrl;
context.urlProductId = urlProductId;
context.productId = productId;
context.productName = productName;
context.wrappedProductName = StringUtil.wrapString(productName);
context.productFeatureAndAppls = productFeatureAndAppls;
context.productFeatureTypesMap = productFeatureTypesMap;
context.cartLine = cartLine;
context.cartLineIndex = cartLineIndex;
context.displayPrice = displayPrice;
context.offerPrice = offerPrice;
context.recurrencePrice = recurrencePrice;
context.recurrenceItem = recurrenceItem;
context.recurrenceSavePercent = recurrenceSavePercent;
context.currencyUom = currencyUom;
context.quantity = quantity;
context.itemSubTotal = cartLine.getDisplayItemSubTotal();
context.cartItemAdjustment = cartItemAdjustment;
context.stockInfo = stockInfo;
context.inStock = inStock;
context.showGiftMessageLink = showGiftMessageLink;
context.cartAttrMap = cartAttrMap;
context.showEditLabel = showEditLabel;



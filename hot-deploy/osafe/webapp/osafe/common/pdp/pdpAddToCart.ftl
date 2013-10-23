<li class="${request.getAttribute("attributeClass")!}">
  <#if pdpSelectMultiVariant?exists && pdpSelectMultiVariant?has_content && ((pdpSelectMultiVariant.toUpperCase() == "QTY") || (pdpSelectMultiVariant.toUpperCase() == "CHECKBOX")) >
    <div class="multiVariant">
       <input type="hidden" name="add_category_id" value="${parameters.add_category_id!productCategoryId!}" /> 
       <a href="javascript:addMultiItems('${pdpSelectMultiVariant}','addToCart');" class="standardBtn addToCart" id="addMultiToCart"><span>${uiLabelMap.OrderAddToCartBtn}</span></a>
    </div>
  <#else>
    <#if (currentProduct.isVirtual?if_exists?upper_case == "N" && currentProduct.isVariant?if_exists?upper_case == "N")>
      <#if (inventoryLevel?number gt inventoryOutOfStockTo?number)>
        <input type="hidden" name="add_product_id" value="${currentProduct.productId!}" />
      </#if>
    </#if>
    <input type="hidden" name= "add_category_id" id="add_category_id" value="${parameters.add_category_id!productCategoryId!}" /> 
    <div>
      <#if inStock>
        <a href="javascript:void(0);" onClick="javascript:addItem('addToCart');" class="standardBtn addToCart <#if featureOrder?exists && featureOrder?size gt 0>inactiveAddToCart</#if>" id="js_addToCart"><span>${uiLabelMap.OrderAddToCartBtn}</span></a>
      <#elseif !isSellable>
        <a href="javascript:void(0);" class="standardBtn addToCart inactiveAddToCart" id="js_addToCart"><span>${uiLabelMap.OrderAddToCartBtn}</span></a>
      <#else>
        <span>${uiLabelMap.OutOfStockLabel}</span>
      </#if>
    </div>
  </#if>
</li>
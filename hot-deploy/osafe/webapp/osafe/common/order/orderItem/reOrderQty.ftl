<li class="${request.getAttribute("attributeClass")!}">
    <div>
      <label>${uiLabelMap.ReOrderQtyCaption}</label>
      <#if productBuyable == 'true'>
        <#assign qtyInCart = 0?number />
        <#if shoppingCart?has_content>
           <#list shoppingCart.items() as cartLine>
             <#if cartLine.getProductId() == productId>
              <#assign qtyInCart = cartLine.getQuantity() />
              <#if cartItemMap?exists && cartItemMap.containsKey(cartLine.getProductId())>
                 <#assign qtyInCart = qtyInCart + cartItemMap.get(cartLine.getProductId()) />
              <#else>
                 <#assign qtyInCart = cartLine.getQuantity() />
              </#if>
              <#assign cartItemMap = Static["org.ofbiz.base.util.UtilMisc"].toMap(cartLine.getProductId(), qtyInCart)/>
             </#if>
           </#list>
        </#if>
	     <input type="hidden" name= "qtyInCart_${productId}" id="js_qtyInCart_${productId}" value="${qtyInCart}" />
         <input type="text" class="js_add_multi_product_quantity" name="add_multi_product_quantity_${idx}" id="js_add_multi_product_quantity_${idx}" value="${quantityOrdered!}" onBlur="javascript:seqReOrderCheck(this);"/>
      <#else>
        <span>${uiLabelMap.ProductNoLongerAvailableInfo}</span>
      </#if> 
    </div>
</li>
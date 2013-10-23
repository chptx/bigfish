<#if isFinishedGood>
  <li class="${request.getAttribute("attributeClass")!}">
   <div>
    <label>${uiLabelMap.CartItemAddToCartButtonCaption}</label>
    <a href="javascript:void(0);" onClick="javascript:plpAddItems('plpAddToCart','${plpProductId!}','${plpCategoryId!}','${plpProductName!}','${uiSequenceScreen!""}');" class="standardBtn addToCart <#if inStock>plpInStock<#else>plpOutOfStock</#if>" id="plpAddtoCart"><span>${uiLabelMap.OrderAddToCartBtn}</span></a>
   </div>
  </li>   
</#if>
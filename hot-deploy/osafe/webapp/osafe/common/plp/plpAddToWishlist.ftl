<#if isFinishedGood>
  <li class="${request.getAttribute("attributeClass")!}">
   <div>
    <a href="javascript:void(0);" onClick="javascript:plpAddItems('plpAddToWishlist','${plpProductId!}','${plpCategoryId!}','${plpProductName!}','${uiSequenceScreen!""}');" class="standardBtn addToWishlist" id="js_addToWishlist"><span>${uiLabelMap.AddToWishlistBtn}</span></a>
   </div>
  </li>   
</#if>
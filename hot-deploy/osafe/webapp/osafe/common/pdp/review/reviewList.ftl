<#if productReviews?has_content>
  <li class="${request.getAttribute("attributeClass")!}">
    <div class="js_pdpReviewList">
      <div id="productReviewDisplay" class="displayBox">
  	    <h3>${uiLabelMap.ProductReviewsHeading}</h3>
        <a name="productReviews" id="js_productReviews"></a>
        <input type="hidden" class="reviewParam" name="productId" value="${productId?if_exists}">
        <input type="hidden" class="reviewParam" name="viewSize" value="${viewSize?if_exists}">
        <input type="hidden" class="reviewParam" name="viewIndex" value="${viewIndex?if_exists}">
        <input type="hidden" class="reviewParam" name="sortReviewBy" value="">
        ${screens.render("component://osafe/widget/EcommerceDivScreens.xml#${reviewScreenPrefix!}ReviewListDivSequence")}
      </div> <!-- end of productReviewDisplay div -->
    </div> <!-- end of pdpReviewList div -->
  </li>
</#if>

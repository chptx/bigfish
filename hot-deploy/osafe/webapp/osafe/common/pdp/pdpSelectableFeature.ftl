<#if currentProduct.isVirtual?if_exists?upper_case == "Y">
  <li class="${request.getAttribute("attributeClass")!}">
   <div class="pdpSelectableFeature">
	<#assign inStock = true />
	<#assign isSellable = Static["org.ofbiz.product.product.ProductWorker"].isSellable(currentProduct?if_exists) />
	<#if !isSellable>
	 <#assign inStock=false/>
	</#if>
	  <#if pdpSelectMultiVariant?exists && pdpSelectMultiVariant?has_content && ((pdpSelectMultiVariant.toUpperCase() == "QTY") || (pdpSelectMultiVariant.toUpperCase() == "CHECKBOX")) && variantProductAssocList?exists >
	    <ul class="multiVariantList">
	      <#assign idCount = 0 />
	      <!--Traverse through all the variant products-->
	      <#list variantProductAssocList as variantProductAssoc>
	        <!--Use the Maps made in the groovy to get product info [Note: Only sellable items are in Map] -->
	        <#if productVariantProductMap.get(variantProductAssoc.productIdTo)?exists && productVariantProductMap.get(variantProductAssoc.productIdTo)?has_content >
	          <li>
	            <!-- build string with all selectable features to display -->
	            <#if productVariantStandardFeatureMap.get(variantProductAssoc.productIdTo)?exists && productVariantStandardFeatureMap.get(variantProductAssoc.productIdTo)?has_content >
			      <#assign featureDescriptionList = productVariantStandardFeatureMap.get(variantProductAssoc.productIdTo)! />
			      <#assign featureDescListString = "">
			      <#list featureDescriptionList as featureValue >
				    <#assign hasNextGroup = featureValue_has_next />
				    <#if hasNextGroup>
			          <#assign featureDescListString = featureDescListString + featureValue.description + ", " />
				    <#else>
				      <#assign featureDescListString = featureDescListString + featureValue.description />
				    </#if>
			      </#list>
			    </#if>
			    <!-- check if outOfStock -->
			    <#assign isInStock = true />
			    <#if (inventoryMethod?exists && inventoryMethod?has_content)>
			      <#if inventoryMethod.toUpperCase() == "BIGFISH">
			        <#if (productVariantStockMap?exists && productVariantStockMap?has_content)>
			         <#assign productAssocProductIdTo = productVariantStockMap.get(variantProductAssoc.productIdTo)!""/>
			         <#if productAssocProductIdTo?has_content>
			            <#if productAssocProductIdTo == "outOfStock">
   			                 <#assign isInStock = false />
			            </#if>
			         </#if>
			        </#if>
			      </#if>
			    </#if>
	            <!-- Use Checkbox implementation -->
	            <#if (pdpSelectMultiVariant.toUpperCase() == "CHECKBOX") >
	              <div class="entry multiVariantCheckbox <#if !isInStock >outOfStockCheckBox</#if>">
	                <input type="checkbox" class="checkbox add_multi_product_id" name="add_multi_product_id_${idCount}" id="js_add_multi_product_id_${idCount}" value="${variantProductAssoc.productIdTo}" <#if ((add_multi_product_id?has_content && add_multi_product_id == "${variantProductAssoc.productIdTo}") || (variantProductAssocList?size == 1))>checked</#if> <#if !isInStock >disabled="disabled"</#if> />
	                <#-- <span>${featureDescListString}</span> -->
	                <span>${featureDescListString}</span>
	                <input type="hidden" class="js_add_multi_product_quantity" name="add_multi_product_quantity_${idCount}" id="js_add_multi_product_quantity_${idCount}" value="1" />
	              </div>
	            <!-- Use Quantity input implementation --> 
	            <#elseif (pdpSelectMultiVariant.toUpperCase() == "QTY")>
	        	  <div class="entry multiVariantQty <#if !isInStock >outOfStockInput</#if>">
	        	    <input type="input" class="js_add_multi_product_quantity" name="add_multi_product_quantity_${idCount}" id="js_add_multi_product_quantity_${idCount}" value="" <#if !isInStock >disabled="disabled"</#if> /><span>${featureDescListString}</span>
	                <input type="hidden" class="add_multi_product_id" name="add_multi_product_id_${idCount}" id="js_add_multi_product_id_${idCount}" value="${variantProductAssoc.productIdTo}"/>
	              </div>
	            </#if>
	          </li>
	          <#assign idCount = idCount + 1 />
	        </#if>
	      </#list>
	    </ul>	    
	  <#else>
	    <!-- If PLP_SELECT_MULTI_VARIANT does not equal QTY or CHECKBOX then display the appropriate display on PDP -->
	    <#if !currentProduct.virtualVariantMethodEnum?exists || currentProduct.virtualVariantMethodEnum == "VV_VARIANTTREE">
	      <#assign pdpSwatchImageHeight = Static["com.osafe.util.Util"].getProductStoreParm(request,"IMG_SIZE_PDP_SWATCH_H")!""/>
	      <#assign pdpSwatchImageWidth = Static["com.osafe.util.Util"].getProductStoreParm(request,"IMG_SIZE_PDP_SWATCH_W")!""/>
	      <#if variantTree?exists && (variantTree.size() > 0)>
	        <#assign featureOrderSize = featureOrder?size>
	        <#assign featureIdx=0/>
	        <#list featureSet as productFeatureTypeId>
	          <#assign featureIdx=featureIdx + 1/>
	          <div class="selectableFeatures ${productFeatureTypeId}">
	            <#assign productFeatureTypeLabel = ""/>
	            <#if productFeatureTypesMap?has_content>
	              <#assign productFeatureTypeLabel = productFeatureTypesMap.get(productFeatureTypeId)!"" />
	            </#if>
	            <label>${productFeatureTypeLabel!productFeatureTypeId.toLowerCase()?replace("_"," ")}:</label>
	            <select class="js_selectableFeature_${featureIdx}" name="FT${productFeatureTypeId}" onchange="javascript:getList(this.name,(this.selectedIndex-1), 1);">
	              <option></option>
	            </select>
	            <#assign productFeatureAndApplsSelects = productFeatureAndApplSelectMap.get(productFeatureTypeId)!""/>
	            <#assign selectedIdx=0/>
	            <#assign alreadyShownProductFeatureId = Static["javolution.util.FastList"].newInstance()/>
	            <#assign productFeatureSize = productFeatureAndApplsSelects?size/>
	            <ul class="js_selectableFeature_${featureIdx}" id="LiFT${productFeatureTypeId}" name="LiFT${productFeatureTypeId}">
	              <#list productFeatureAndApplsSelects as productFeatureAndApplsSelect>
	                <#assign productFeatureDescription =productFeatureAndApplsSelect.description/>
	                <#assign productFeatureSelectableId =productFeatureAndApplsSelect.productFeatureId/>
	                <#if PDP_FACET_GROUP_VARIANT_SWATCH?has_content && productFeatureTypeId.equalsIgnoreCase(PDP_FACET_GROUP_VARIANT_SWATCH)>
	                  <#assign productFeatureSelectVariantId= productFeatureFirstVariantIdMap.get(productFeatureSelectableId)!""/>
	                  <#assign productFeatureId = productFeatureSelectableId />
	                  <#if productFeatureSelectVariantId?has_content>
	                    <#if !alreadyShownProductFeatureId.contains(productFeatureSelectVariantId)>
	                      <#assign variantProdCtntWrapper = productVariantContentWrapperMap.get(productFeatureSelectVariantId)!""/>
	                      <#assign variantContentIdMap = productVariantProductContentIdMap.get(productFeatureSelectVariantId)!""/>
	                      <#assign productVariantPdpSwatchURL=""/>                               
	                      <#if variantContentIdMap?has_content>
	                        <#assign variantContentId = variantContentIdMap.get("PDP_SWATCH_IMAGE_URL")!""/>
	                        <#if variantContentId?has_content>
	                          <#assign productVariantPdpSwatchURL = variantProdCtntWrapper.get("PDP_SWATCH_IMAGE_URL")!"">
	                        </#if>
	                      </#if>
	                      <#if (productVariantPdpSwatchURL?string?has_content)>
	                        <#assign productFeatureSwatchURL=productVariantPdpSwatchURL/>
	                      <#else>
	                        <#if productFeatureDataResourceMap?has_content>
	                          <#assign productFeatureResourceUrl = productFeatureDataResourceMap.get(productFeatureId)!""/>
	                          <#if productFeatureResourceUrl?has_content>
	                            <#assign productFeatureSwatchURL=productFeatureResourceUrl/>
	                          </#if>
	                        </#if>
	                      </#if>
	                      <#if featureOrderSize == 1>
	                        <#assign variantProductInventoryLevel = productVariantInventoryMap.get(productFeatureSelectVariantId)!/>
	                        <#assign inventoryLevel = variantProductInventoryLevel.get("inventoryLevel")/>
	                        <#assign inventoryInStockFrom = variantProductInventoryLevel.get("inventoryLevelInStockFrom")/>
	                        <#assign inventoryOutOfStockTo = variantProductInventoryLevel.get("inventoryLevelOutOfStockTo")/>
	                        <#if (inventoryLevel?number <= inventoryOutOfStockTo?number)>
	                          <#assign stockClass = "outOfStock"/>
	                        <#else>
	                          <#if (inventoryLevel?number >= inventoryInStockFrom?number)>
	                            <#assign stockClass = "inStock"/>
	                          <#else>
	                            <#assign stockClass = "lowStock"/>
	                          </#if>
	                        </#if>
	                      </#if>
	                      <#assign productFeatureType = "${productFeatureTypeId!}:${productFeatureDescription!}"/>
	                      <#assign variantProductUrl = Static["com.osafe.services.CatalogUrlServlet"].makeCatalogFriendlyUrl(request, "eCommerceProductDetail?productId=${productId!}&productCategoryId=${productCategoryId!}&productFeatureType=${productFeatureTypeId!}:${productFeatureDescription!}") />
	                      <input type="hidden" id="${jqueryIdPrefix!}Url_${productFeatureDescription!}" value="${variantProductUrl!}"/>
	                      <#assign selectedClass="false"/>
	                      <#if parameters.productFeatureType?exists>
	                        <#assign productFeatureTypeIdParm = parameters.productFeatureType.split(":")/>
	                        <#if parameters.productFeatureType.equals(productFeatureType)>
	                          <#assign productFeatureIdx = selectedIdx/>
	                          <#assign selectedClass="true"/>
	                        </#if>
	                      </#if>
	                      <#if !parameters.productFeatureType?exists || productFeatureTypeId != productFeatureTypeIdParm[0]!"">
	                        <#if selectedIdx == 0>
	                          <#assign selectedClass="true"/>
	                        </#if>
	                      </#if>
	                      <li class="<#if selectedClass == "true">js_selected</#if><#if stockClass?exists> ${stockClass}</#if>">
	                        <a href="javascript:void(0);" class="pdpFeatureSwatchLink" onclick="javascript:getList('FT${productFeatureTypeId}','${selectedIdx}', 1);">
	                          <img src="<@ofbizContentUrl>${productFeatureSwatchURL!""}</@ofbizContentUrl>" class="js_pdpFeatureSwatchImage" title="${productFeatureDescription!""}" alt="${productFeatureDescription!""}" name="FT${productFeatureTypeId}" <#if pdpSwatchImageHeight != '0' && pdpSwatchImageHeight != ''>height = "${pdpSwatchImageHeight}"</#if> <#if pdpSwatchImageWidth != '0' && pdpSwatchImageWidth != ''>width = "${pdpSwatchImageWidth}"</#if> onerror="onImgError(this, 'PDP-Swatch');"/>
	                        </a>
	                      </li>
	                      <#assign changed = alreadyShownProductFeatureId.add(productFeatureSelectVariantId)/>
	                    </#if>
	                  </#if>
	                <#else>
	                  <li>
	                    <a href="javascript:void(0);" onclick="javascript:getList('FT${productFeatureTypeId}','${selectedIdx}', 1);">
	                      ${productFeatureDescription!""}
	                    </a>
	                  </li>
	                </#if>
	                <#assign selectedIdx=selectedIdx + 1/>
	              </#list>
	            </ul>
	            <#--<select name="FT${productFeatureTypeId}" id="FT${productFeatureTypeId}">
	            <option></option>
	            </select> -->
	          </div>
	        </#list>
	        <input type="hidden" name="product_id" value="${currentProduct.productId}"/>
	        <input type="hidden" name="add_product_id" id="js_add_product_id" value="NULL"/>
	        <div class="selectableFeatureAddProductId">
	          <span id="product_id_display"> </span>
	          <div id="variant_price_display"> </div>
	        </div>
	      <#else>
	        <input type="hidden" name="product_id" value="${currentProduct.productId}"/>
	        <input type="hidden" name="add_product_id" value="NULL"/>
	        <#assign inStock = false>
	      </#if>
	    </#if>
	    <#-- Prefill first select box (virtual products only) -->
	    <#if variantTree?exists && 0 < variantTree.size()>
	      <#assign rowNo = 0/>
	      <#list featureOrder as feature>
	          <#if rowNo == 0>
	              <script language="JavaScript" type="text/javascript">eval("list" + "${StringUtil.wrapString(feature)}" + "()");</script>
	          <#else>
	              <script language="JavaScript" type="text/javascript">eval("listFT" + "${StringUtil.wrapString(feature)}" + "()");</script>
	              <script language="JavaScript" type="text/javascript">eval("listLiFT" + "${StringUtil.wrapString(feature)}" + "()");</script>
	          </#if>
	      <#assign rowNo = rowNo + 1/>
	      </#list> 
	    </#if>
	  </#if>
	
	<#assign shoppingCart = sessionAttributes.shoppingCart?if_exists />
	<#if currentProduct.isVirtual?if_exists?upper_case == "Y">
    	<#if variantProductAssocList?has_content>
	    <#list variantProductAssocList as variantProductAssoc>
	        <#assign qtyInCart = 0?number />
            <#if shoppingCart?has_content>
                <#list shoppingCart.items() as cartLine>
                  <#if cartLine.getProductId() == variantProductAssoc.productIdTo>
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
	        <input type="hidden" name= "qtyInCart_${variantProductAssoc.productIdTo}" id="js_qtyInCart_${variantProductAssoc.productIdTo}" value="${qtyInCart}" />
	    </#list>
	   </#if>
	<#else>
	    <#assign qtyInCart = 0?number />
            <#if shoppingCart?has_content>
                <#list shoppingCart.items() as cartLine>
                  <#if cartLine.getProductId() == currentProduct.productId>
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
	    <input type="hidden" name= "qtyInCart_${currentProduct.productId}" id="js_qtyInCart_${currentProduct.productId}" value="${qtyInCart}" />
	</#if>
   </div>
  </li>
</#if>

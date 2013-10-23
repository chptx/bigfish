package com.osafe.services;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;

import javolution.util.FastList;
import javolution.util.FastMap;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.ofbiz.base.util.UtilMisc;
import org.ofbiz.base.util.UtilXml;
import org.ofbiz.base.util.UtilXml.LocalErrorHandler;
import org.ofbiz.base.util.UtilXml.LocalResolver;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * OsafeManageXmlMerge
 */

public class OsafeManageXmlMerge {

    public static final String delimiter = ",";
    public static final String keyAtrrName = "key";
    public static final String divNodeName = "div";
    public static final String screenNodeName = "screen";
    public static final String excludeKeyForUpdate = "style,value,group";
    public static Map<String, String> screenNamePrefixMap = new HashMap<String, String>();
    static
    {
        screenNamePrefixMap.put("manufacturerProductList", "manufacturerItem");
        screenNamePrefixMap.put("showCartOrderItems", "showCart");
        screenNamePrefixMap.put("orderSummaryOrderItems", "orderSummary");
        screenNamePrefixMap.put("orderConfirmOrderItems", "orderConfirm");
        screenNamePrefixMap.put("showCartOrderItemsSummary", "showCart");
        screenNamePrefixMap.put("orderSummaryOrderItemsSummary", "orderSummary");
        screenNamePrefixMap.put("orderConfirmOrderItemsSummary", "orderConfirm");
        screenNamePrefixMap.put("showWishlistOrderItems", "showWishlist");
        screenNamePrefixMap.put("showWishlistOrderItemsSummary", "showWishlist");
        screenNamePrefixMap.put("lightBoxOrderItems", "lightBox");
        screenNamePrefixMap.put("lightBoxOrderItemsSummary", "lightBox");
        screenNamePrefixMap.put("writeReviewProduct", "writeReview");
        screenNamePrefixMap.put("writeReviewRating", "writeReviewRate");
        screenNamePrefixMap.put("writeReviewDetail", "writeReview");
        screenNamePrefixMap.put("writeReviewAboutYou", "writeReview");
        screenNamePrefixMap.put("writeReviewLink", "writeReview");
        screenNamePrefixMap.put("writeReviewButton", "writeReview");
    }

    public static void main(String args[]) throws Exception
    {
        if (args.length == 3)
        {
            mergeXmlFile(args[0], args[1], args[2]);
        }
        else
        {
            System.out.println("Please include the xml paths for merge file.");
        }
    }

    public static void mergeXmlFile(String fromXmlFilePath, String toXmlFilePath, String keyValues)
    {
        try
        {
            if (isEmpty(fromXmlFilePath) || isEmpty(toXmlFilePath) || isEmpty(keyValues))
            {
                return;
            }

            // chaeck xml existance on instance; if its not exist then copy the from file on that location
            if (!(new File(toXmlFilePath)).exists())
            {
                FileUtils.copyFile(new File(fromXmlFilePath), new File(toXmlFilePath));
                return;
            }

            List<Map<Object, Object>> fromEntryList = getListMapsFromXmlFile(fromXmlFilePath, null);
            List<Map<Object, Object>> toEntryList = getListMapsFromXmlFile(toXmlFilePath, null);
            String[] keyList = StringUtils.split(keyValues, delimiter);
            List<String> excludeKeyList = UtilMisc.toListArray(StringUtils.split(excludeKeyForUpdate, delimiter));

            Document fromXmlDocument = readXmlDocument(fromXmlFilePath);
            if (isNotEmpty(fromXmlDocument))
            {
                Iterator<Map<Object, Object>> fromEntryListIter = fromEntryList.iterator();
                while (fromEntryListIter.hasNext())
                {
                    try
                    {
                        Map<Object, Object> fromMapEntry = fromEntryListIter.next();
                        Map<Object, Object> searchMap = FastMap.newInstance();
                        for (String key : keyList)
                        {
                            searchMap.put(key, fromMapEntry.get(key));
                        }
                        Map<Object, Object> toMapEntry = findFromListMaps(toEntryList, searchMap);

                        // Logic for support old sequence format
                        if (isEmpty(toMapEntry) && isNotEmpty(fromMapEntry.get(screenNodeName)))
                        {
                            //Case 1: IF DIV is replaced by new key
                            searchMap = FastMap.newInstance();
                            searchMap.put(divNodeName, fromMapEntry.get(keyAtrrName));
                            toMapEntry = findFromListMaps(toEntryList, searchMap);

                            if (isEmpty(toMapEntry))
                            {
                                String screenValue = fromMapEntry.get(screenNodeName).toString();
                                screenValue = Character.toLowerCase(screenValue.charAt(0)) + (screenValue.length() > 1 ? screenValue.substring(1) : "");
                                if (isNotEmpty(screenNamePrefixMap.get(screenValue)))
                                {
                                    String oldDivName = fromMapEntry.get(keyAtrrName).toString().replaceFirst(screenValue, screenNamePrefixMap.get(screenValue));

                                    //Case 2: IF DIV is different from new key
                                    searchMap = FastMap.newInstance();
                                    searchMap.put(divNodeName, oldDivName);
                                    toMapEntry = findFromListMaps(toEntryList, searchMap);

                                    if (isEmpty(toMapEntry))
                                    {
                                        //Case 3: IF KEY is different from new key
                                        searchMap = FastMap.newInstance();
                                        searchMap.put(keyAtrrName, oldDivName);
                                        toMapEntry = findFromListMaps(toEntryList, searchMap);
                                    }
                                }
                            }
                        }

                        if (isNotEmpty(toMapEntry))
                        {
                            fromXmlDocument = updateXmlEntry(fromXmlDocument, fromMapEntry, toMapEntry, excludeKeyList);
                        }
                    }
                    catch (Exception exc)
                    {
                        System.err.println("Error in mergeing=="+exc.getMessage());
                    }
                }
                writeXmlDocument(fromXmlDocument, toXmlFilePath);
            }
        }
        catch (Exception exc)
        {
            System.err.println("Error in mergeing=="+exc.getMessage());
        }
    }

    public static Document updateXmlEntry(Document fromXmlDocument, Map<Object, Object> fromXmlEntry, Map<Object, Object> toXmlEntry, List<String> excludeKeyList) throws Exception
    {
        if (isNotEmpty(fromXmlDocument)) 
        {
            List<? extends Node> nodeList = UtilXml.childNodeList(fromXmlDocument.getDocumentElement().getFirstChild());
            for (Node node: nodeList)
            {
                Boolean found = Boolean.FALSE;
                if (node.getNodeType() == Node.ELEMENT_NODE) 
                {
                    if (isMatch(getAllNameValueMap(node), fromXmlEntry))
                    {
                        found = Boolean.TRUE;
                    }
                }
                if (found)
                {
                    List<? extends Node> childNodeList = UtilXml.childNodeList(node.getFirstChild());
                    for(Node childNode: childNodeList)
                    {
                        if (excludeKeyList.contains(childNode.getNodeName()) && isNotEmpty(toXmlEntry.get(childNode.getNodeName())))
                        {
                            childNode.setTextContent((String)toXmlEntry.get(childNode.getNodeName()));
                        }
                    }
                    break;
                }
            }
        }
        return fromXmlDocument;
    }

    /**
     * read xml document and make List of Maps of element.
     * @param XmlFilePath String xml file path
     * @return a new List of  Maps.
     */
    public static List<Map<Object, Object>> getListMapsFromXmlFile(String XmlFilePath)
    {
        return getListMapsFromXmlFile(XmlFilePath, null);
        
    }
    
    public static List<Map<Object, Object>> getListMapsFromXmlFile(String XmlFilePath, String activChildName)
    {
        List<Map<Object, Object>> listMaps = FastList.newInstance();
        InputStream ins = null;
        URL xmlFileUrl = null;
        Document xmlDocument = null;
        try
        {
            if (isNotEmpty(XmlFilePath))
            {
                xmlFileUrl = fromFilename(XmlFilePath);
                if (isNotEmpty(xmlFileUrl)) ins = xmlFileUrl.openStream();
                if (isNotEmpty(ins))
                {
                    xmlDocument = readXmlDocument(ins, xmlFileUrl.toString());
                    List<? extends Node> nodeList = FastList.newInstance();
                    if (isNotEmpty(activChildName))
                    {
                        nodeList = UtilXml.childElementList(xmlDocument.getDocumentElement(), activChildName);
                    }
                    else 
                    {
                        nodeList = UtilXml.childNodeList(xmlDocument.getDocumentElement().getFirstChild());
                    }
                    
                    for (Node node: nodeList)
                    {
                        if (node.getNodeType() == Node.ELEMENT_NODE)
                        {
                            listMaps.add(getAllNameValueMap(node));
                        }
                    }
                }
            }
        }
        catch (Exception exc)
        {
            System.err.println("Error reading xml file"+exc.getMessage());
        }
        finally
        {
            try
            {
                if (isNotEmpty(ins)) ins.close();
            }
            catch (Exception exc)
            {
                System.err.println("Error reading xml file"+exc.getMessage());
            }
        }
        return listMaps;
    }

    public static Map<Object, Object> findFromListMaps(List<Map<Object, Object>> listOfMaps, Map<Object, Object> searchMap)
    {
        Map<Object, Object> rowMap = FastMap.newInstance();
        try
        {
            if (isEmpty(listOfMaps) || isEmpty(searchMap))
            {
                return rowMap;
            }
            Iterator<Map<Object, Object>> listOfMapsIter = listOfMaps.iterator();
            while (listOfMapsIter.hasNext())
            {
                Map<Object, Object> mapEntry = listOfMapsIter.next();
                if (isMatch(mapEntry, searchMap))
                {
                    rowMap = mapEntry;
                    break;
                }
            }
        } catch (Exception exc) {
            System.err.println("Error in searching"+exc.getMessage());
        }
        return rowMap;
    }

    // Match the two Map as partial
    private static boolean isMatch(Map<Object, Object> fromMap, Map<Object, Object> toMap)
    {
        if (isEmpty(fromMap) || isEmpty(toMap))
        {
            return false;
        }

        Boolean match = Boolean.TRUE;
        Set<Object> toKeys = toMap.keySet();
        Iterator<Object> toKeyIter = toKeys.iterator();
        while (toKeyIter.hasNext())
        {
            Object toKey = toKeyIter.next();
            if (!areEqual(fromMap.get(toKey), toMap.get(toKey)))
            {
                match = Boolean.FALSE;
            }
        }

        return match;
    }

    private static Map<Object, Object> getAllNameValueMap(Node node)
    {

        Map<Object, Object> allFields = FastMap.newInstance();
        if (isNotEmpty(node))
        {
            Map<Object, Object> attrFields = getAttributeNameValueMap(node);
            Set<Object> keys = attrFields.keySet();
            Iterator<Object> attrFieldsIter = keys.iterator();
            while (attrFieldsIter.hasNext())
            {
                Object key = attrFieldsIter.next();
                allFields.put(key, attrFields.get(key));
            }

            List<? extends Node> childNodeList = UtilXml.childNodeList(node.getFirstChild());
            if (isNotEmpty(childNodeList))
            {
                for(Node childNode: childNodeList)
                {
                    allFields.put(childNode.getNodeName(), UtilXml.elementValue((Element)childNode));
                    attrFields = getAttributeNameValueMap(childNode);
                    keys = attrFields.keySet();
                    attrFieldsIter = keys.iterator();
                    while (attrFieldsIter.hasNext())
                    {
                        Object key = attrFieldsIter.next();
                        allFields.put(key, attrFields.get(key));
                    }
                }
            }
        }
        return allFields;
    }
    /**
     * Create a map from element
     * @param node Node container element node
     * @return The resulting Map
     */
    private static Map<Object, Object> getAttributeNameValueMap(Node node)
    {
        Map<Object, Object> attrFields = FastMap.newInstance();
        if (isNotEmpty(node))
        {
            if (node.getNodeType() == Node.ELEMENT_NODE)
            {
                NamedNodeMap attrNodeList = node.getAttributes();
                for (int a = 0; a < attrNodeList.getLength(); a++)
                {
                    Node attrNode = attrNodeList.item(a);
                    attrFields.put(attrNode.getNodeName(), attrNode.getNodeValue());
                }
            }
        }
        return attrFields;
    }

    public static void addXmlEntry(String fromXmlFilePath, String toXmlFilePath, Map<Object, Object> XmlEntry)
    {
        Document fromXmlDocument = readXmlDocument(fromXmlFilePath);
        Document toXmlDocument = readXmlDocument(toXmlFilePath);
        if (isNotEmpty(fromXmlDocument) && isNotEmpty(toXmlDocument)) 
        {
            try
            {
                List<? extends Node> nodeList = UtilXml.childNodeList(fromXmlDocument.getDocumentElement().getFirstChild());
                for (Node node: nodeList)
                {
                    Boolean found = Boolean.FALSE;
                    if (node.getNodeType() == Node.ELEMENT_NODE) 
                    {
                        if (isMatch(getAllNameValueMap(node), XmlEntry))
                        {
                            found = Boolean.TRUE;
                        }
                    }
                    if (found)
                    {
                        Node importNode = toXmlDocument.importNode(node, true);
                        toXmlDocument.getDocumentElement().appendChild(importNode);
                        break;
                    }
                }
                writeXmlDocument(toXmlDocument, toXmlFilePath);
            }
            catch (Exception exc)
            {
                System.err.println("Error in addXmlEntry="+XmlEntry+"==error=="+exc.getMessage());
            }
        }
    }

    public static void updateXmlEntry(String toXmlFilePath, Map<Object, Object> toXmlEntry, Map<Object, Object> fromXmlEntry)
    {
        Document toXmlDocument = readXmlDocument(toXmlFilePath);
        if (isNotEmpty(toXmlDocument)) 
        {
            try
            {
                List<? extends Node> nodeList = UtilXml.childNodeList(toXmlDocument.getDocumentElement().getFirstChild());
                for (Node node: nodeList)
                {
                    Boolean found = Boolean.FALSE;
                    if (node.getNodeType() == Node.ELEMENT_NODE) 
                    {
                        if (isMatch(getAllNameValueMap(node), toXmlEntry))
                        {
                            found = Boolean.TRUE;
                        }
                    }
                    if (found)
                    {
                        List<? extends Node> childNodeList = UtilXml.childNodeList(node.getFirstChild());
                        for(Node childNode: childNodeList)
                        {
                            if (!areEqual(childNode.getNodeName(), excludeKeyForUpdate) && isNotEmpty(fromXmlEntry.get(childNode.getNodeName())))
                            {
                                childNode.setTextContent((String)fromXmlEntry.get(childNode.getNodeName()));
                            }
                        }
                        break;
                    }
                }
                writeXmlDocument(toXmlDocument, toXmlFilePath);
            }
            catch (Exception exc)
            {
                System.err.println("Error in updateXmlEntry="+toXmlEntry+"==error=="+exc.getMessage());
            }
        }
    }

    public static void removeXmlEntry(String xmlFilePath, Map<Object, Object> XmlEntry)
    {
        Document xmlDocument = readXmlDocument(xmlFilePath);
        if (isNotEmpty(xmlDocument)) 
        {
            try
            {
                List<? extends Node> nodeList = UtilXml.childNodeList(xmlDocument.getDocumentElement().getFirstChild());
                for (Node node: nodeList)
                {
                    Boolean found = Boolean.FALSE;
                    if (node.getNodeType() == Node.ELEMENT_NODE) 
                    {
                        if (isMatch(getAllNameValueMap(node), XmlEntry))
                        {
                            found = Boolean.TRUE;
                        }
                    }
                    if (found)
                    {
                        node.getParentNode().removeChild(node);
                        break;
                    }
                }
                writeXmlDocument(xmlDocument, xmlFilePath);
            }
            catch (Exception exc)
            {
                System.err.println("Error in removeXmlEntry="+XmlEntry+"==error=="+exc.getMessage());
            }
        }
    }

    public static boolean writeXmlDocument(Document xmlDocument, String XmlFilePath) {
        if (isEmpty(xmlDocument) || isEmpty(XmlFilePath) )
        {
            return false;
        }
        OutputStream os = null;
        URL xmlFileUrl = fromFilename(XmlFilePath);
        if (isEmpty(xmlFileUrl)) return false;
        try
        {
            xmlDocument.normalize();
            os = new FileOutputStream(xmlFileUrl.getPath());
            Transformer transformer = createOutputTransformer("UTF-8", false, true, 4, true);
            UtilXml.transformDomDocument(transformer, xmlDocument, os);
            if (isNotEmpty(os)) os.close();
        }
        catch (Exception exc)
        {
            System.err.println("Error in writeXmlDocument"+exc.getMessage());
            return false;
        }
        os = null;
        return true;
    }

    public static Document readXmlDocument(String XmlFilePath) {
        InputStream ins = null;
        Document xmlDocument = null;

        URL xmlFileUrl = fromFilename(XmlFilePath);
        if (isEmpty(xmlFileUrl) || !StringUtils.equalsIgnoreCase(FilenameUtils.getExtension(XmlFilePath), "xml"))
        {
            return null;
        }
        try {
            ins = xmlFileUrl.openStream();
            if (isNotEmpty(ins))
            {
                xmlDocument = readXmlDocument(ins, xmlFileUrl.toString());
            }
        }
        catch (Exception e)
        {
            System.err.println("Error in readXmlDocument"+e.getMessage());
            return null;
        }
        finally
        {
            try
            {
                if (isNotEmpty(ins)) ins.close();
            }
            catch (Exception e)
            {
                System.err.println("Error in readXmlDocument"+e.getMessage());
            }
        }
        ins = null;
        return xmlDocument;
    }

    public static Document readXmlDocument(InputStream is, String docDescription)
            throws SAXException, ParserConfigurationException, java.io.IOException {
        return readXmlDocument(is, true, docDescription);
    }

    public static Document readXmlDocument(InputStream is, boolean validate, String docDescription)
            throws SAXException, ParserConfigurationException, java.io.IOException {
        if (isEmpty(is))
        {
            System.err.println("[readXmlDocument] InputStream was null, doing nothing");
            return null;
        }

        Document document = null;

        DocumentBuilderFactory factory = new org.apache.xerces.jaxp.DocumentBuilderFactoryImpl();
        factory.setValidating(validate);
        factory.setNamespaceAware(true);

        factory.setAttribute("http://xml.org/sax/features/validation", validate);
        factory.setAttribute("http://apache.org/xml/features/validation/schema", validate);

        DocumentBuilder builder = factory.newDocumentBuilder();
        if (validate)
        {
            LocalResolver lr = new LocalResolver(new DefaultHandler());
            ErrorHandler eh = new LocalErrorHandler(docDescription, lr);

            builder.setEntityResolver(lr);
            builder.setErrorHandler(eh);
        }
        document = builder.parse(is);

        return document;
    }

    /** Creates a JAXP TrAX Transformer suitable for pretty-printing an
     * XML document. 
     * @param encoding Optional encoding, defaults to UTF-8
     * @param omitXmlDeclaration If <code>true</code> the xml declaration
     * will be omitted from the output
     * @param indent If <code>true</code>, the output will be indented
     * @param indentAmount If <code>indent</code> is <code>true</code>,
     * the number of spaces to indent. Default is 4.
     * @param keepSpace If <code>true</code>, the output will preserve the space
     * @return A <code>Transformer</code> instance
     * @see <a href="http://java.sun.com/javase/6/docs/api/javax/xml/transform/package-summary.html">JAXP TrAX</a>
     * @throws TransformerConfigurationException
     */
    public static Transformer createOutputTransformer(String encoding, boolean omitXmlDeclaration, boolean indent, int indentAmount, boolean preserveSpace) throws TransformerConfigurationException {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        sb.append("<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xalan=\"http://xml.apache.org/xslt\" version=\"1.0\">\n");
        sb.append("<xsl:output method=\"xml\" encoding=\"");
        sb.append(encoding == null ? "UTF-8" : encoding);
        sb.append("\"");
        if (omitXmlDeclaration)
        {
            sb.append(" omit-xml-declaration=\"yes\"");
        }
        sb.append(" indent=\"");
        sb.append(indent ? "yes" : "no");
        sb.append("\"");
        if (indent)
        {
            sb.append(" xalan:indent-amount=\"");
            sb.append(indentAmount <= 0 ? 4 : indentAmount);
            sb.append("\"");
        }
        if (preserveSpace)
        {
            sb.append("/>\n<xsl:preserve-space elements=\"*\"/>\n");
        }
        else
        {
            sb.append("/>\n<xsl:strip-space elements=\"*\"/>\n");
        }
        sb.append("<xsl:template match=\"@*|node()\">\n");
        sb.append("<xsl:copy><xsl:apply-templates select=\"@*|node()\"/></xsl:copy>\n");
        sb.append("</xsl:template>\n</xsl:stylesheet>\n");
        ByteArrayInputStream bis = new ByteArrayInputStream(sb.toString().getBytes());
        TransformerFactory transformerFactory = TransformerFactory.newInstance();
        return transformerFactory.newTransformer(new StreamSource(bis));
    }

    public static boolean isEmpty(Object value)
    {
        if (value == null) return true;

        if (value instanceof String) return ((value == null) || (((String)value).length() == 0));
        if (value instanceof Collection) return ((value == null) || (((Collection<? extends Object>)value).size() == 0));
        if (value instanceof Map) return ((value == null) || (((Map<? extends Object, ? extends Object>)value).size() == 0));
        if (value instanceof CharSequence) return ((value == null) || (((CharSequence)value).length() == 0));

        // These types would flood the log
        // Number covers: BigDecimal, BigInteger, Byte, Double, Float, Integer, Long, Short
        if (value instanceof Boolean) return false;
        if (value instanceof Number) return false;
        if (value instanceof Character) return false;
        if (value instanceof java.sql.Timestamp) return false;
        return false;
    }

    public static boolean isNotEmpty(Object value)
    {
        return !isEmpty(value);
    }

    public static URL fromFilename(String filename) {
        if (filename == null) return null;
        File file = new File(filename);
        URL url = null;

        try {
            if (file.exists()) url = file.toURI().toURL();
        } catch (java.net.MalformedURLException e) {
            e.printStackTrace();
            url = null;
        }
        return url;
    }

    public static boolean areEqual(Object obj, Object obj2) {
        if (obj == null) {
            return obj2 == null;
        } else {
            return obj.equals(obj2);
        }
    }
}
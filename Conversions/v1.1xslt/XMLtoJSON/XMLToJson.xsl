<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="http://www.omg.org/spec/cts2/1.2/function" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    version="2.0">
    <!-- Output method is xml because we needed the "copy-of" function -->
    <xsl:output method="xml" omit-xml-declaration="yes" media-type="application/json"/>

    <xsl:strip-space elements="*"/>

    <!-- Rule 1: Outermost node is an object -->
    <xsl:template match="/">
        <xsl:text>{ </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> }</xsl:text>
    </xsl:template>

    <!-- Match an Element 
         Parameters:
            generatingValues: True means that we're emitting JSONValues, and that tag/values have to be enclosed in braces.
                              False means that we're inside an object, no braces and values have to have a "content:" tag
            inList: True means that we're iterating over multiple elements and that the name should not be emitted.
    -->
    <xsl:template match="*">
        <xsl:param name="generatingValues" as="xs:boolean" select="false()"/>
        <xsl:param name="inList" as="xs:boolean" select="false()"/>

        <xsl:choose>
            <xsl:when test="count(../*[name()=current()/name()]) > 1 and not($inList)">
                <!-- Positioned on an element with more than one occurrence and not processing those elements specifically -->
                <xsl:if test="count(preceding-sibling::node()[name()=current()/name()]) = 0">
                    <!-- First element in the array, emit name and array tag -->
                    <xsl:if test="position() > 1">, </xsl:if>
                    <xsl:call-template name="name"/>
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates select="../node()[name()=current()/name()]">
                        <xsl:with-param name="generatingValues" select="true()"/>
                        <xsl:with-param name="inList" select="true()"/>
                    </xsl:apply-templates>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </xsl:when>

            <xsl:when test="boolean(@_CDATA)">
                <!-- Positioned on a single element or an individual in a list -->
                <xsl:if test="position() > 1">, </xsl:if>
                <xsl:if test="not($inList)">
                    <xsl:call-template name="name"/>
                </xsl:if>

                <!-- Positioned on an element with a CDATA attribute. Treat the same way as attributes and text -->
                <xsl:if test="count(@*[name() != '_CDATA']) > 0">
                    <!-- There are attributes, generate a JSONObject to carry it -->
                    <xsl:text>{ </xsl:text>
                    <xsl:apply-templates select="@*[name() != '_CDATA']"/>
                    <xsl:text>, "content": </xsl:text>
                </xsl:if>

                <!-- Embed the actual data -->
                <xsl:text>"</xsl:text>
                <xsl:apply-templates select="text()|*" mode="cdata"/>
                <xsl:text>"</xsl:text>

                <xsl:if test="count(@*) > 1"> }</xsl:if>
            </xsl:when>

            <xsl:otherwise>
                <!-- Positioned on a normal element -->
                <xsl:if test="position() > 1">, </xsl:if>

                <!-- If not inside a repeating group, generate name/value -->
                <xsl:if test="not($inList)">
                    <!-- If generating elements, then create an object -->
                    <xsl:if test="$generatingValues">{ </xsl:if>
                    <xsl:call-template name="name"/>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="count(*) + count(@*) > 0">
                        <!-- At least one interior element or attribute -->
                        <xsl:choose>
                            <xsl:when test="count(text()) > 0 and count(*) > 0">
                                <!-- Mixed content detected text and elements - make into a JSONArray -->
                                <xsl:text>[</xsl:text>
                                <xsl:apply-templates select="text()|*|@*">
                                    <xsl:with-param name="generatingValues" as="xs:boolean" select="true()"/>
                                </xsl:apply-templates>
                                <xsl:text>]</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- Make into a JSONObject -->
                                <xsl:text>{ </xsl:text>
                                <xsl:apply-templates select="text()|*|@*"/>
                                <xsl:text> }</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="string-length(text()) > 0">
                        <!-- Only text, no attributes, no elements.  Make into JSONMember -->
                        <xsl:apply-templates select="text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- No text, no attributes, no elements. Rule 5: Empty elements become an empty string -->
                        <xsl:text>""</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- If not inside a group and generating elements, close the object tag -->
                <xsl:if test="$generatingValues and not($inList)"> }</xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Match an Attribute 
         Parameters:
            generatingValues: True means that we're emitting JSONValues, and that tag/values have to be enclosed in braces.
                              False means that we're inside an object, no braces and values have to have a "content:" tag
    -->
    <xsl:template match="@*">
        <xsl:param name="generatingValues" as="xs:boolean" select="false()"/>

        <!-- Attributes are represented as JSONMember -->
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:if test="$generatingValues">{ </xsl:if>
        <xsl:call-template name="name"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="$generatingValues"> }</xsl:if>
    </xsl:template>


    <!-- Match an Text 
         Parameters:
            generatingValues: True means that we're emitting JSONValues, and that tag/values have to be enclosed in braces.
                              False means that we're inside an object, no braces and values have to have a "content:" tag
    -->
    <xsl:template match="text()">
        <xsl:param name="generatingValues" as="xs:boolean" select="false()"/>

        <!-- Text as a quoted string -->
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:if test="../@* and not($generatingValues)">"content": </xsl:if>
        <xsl:value-of select="concat('&quot;', f:escape(.), '&quot;')"/>
    </xsl:template>

    <!-- Match on an attribute or element in cdata mode -->
    <xsl:template match="*|@*" mode="cdata">
        <xsl:copy>
            <xsl:apply-templates select="@*|*|text()" mode="cdata"/>
        </xsl:copy>
    </xsl:template>

    <!-- Match on text in cdata mode -->
    <xsl:template match="text()" mode="cdata">
        <xsl:value-of select="f:escape(.)"/>
    </xsl:template>

    <!-- Format a name, removing all namespaces except 'xsi' -->
    <xsl:template name="name">
        <xsl:text>"</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()='http://www.w3.org/2001/XMLSchema-instance'">
                <xsl:value-of select="concat('xsi:',local-name())"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="local-name()"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>": </xsl:text>
    </xsl:template>

    <!-- Escape text, replacing tabs, line feeds, carriage returns, back slashes and quotes -->
    <xsl:function name="f:escape">
        <xsl:param name="text"/>
        <xsl:value-of
            select="replace(
            replace(
            replace(
            replace(
            replace($text,'\\','\\\\'),
            '&quot;','\\&quot;'),
            '\r','\\r'),'\t','\\t'),
            '\n','\\n')"
        />
    </xsl:function>
</xsl:stylesheet>

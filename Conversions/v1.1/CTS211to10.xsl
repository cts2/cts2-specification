<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:core="http://schema.omg.org/spec/CTS2/1.0/Core"
    xmlns:association="http://schema.omg.org/spec/CTS2/1.0/Association"
    xmlns:codesystem="http://schema.omg.org/spec/CTS2/1.0/CodeSystem"
    xmlns:codesystemversion="http://schema.omg.org/spec/CTS2/1.0/CodeSystemVersion"
    xmlns:conceptdomain="http://schema.omg.org/spec/CTS2/1.0/ConceptDomain"
    xmlns:conceptdomainbinding="http://schema.omg.org/spec/CTS2/1.0/ConceptDomainBinding"
    xmlns:entity="http://schema.omg.org/spec/CTS2/1.0/Entity" 
    xmlns:map="http://schema.omg.org/spec/CTS2/1.0/MapCatalog"
    xmlns:mapversion="http://schema.omg.org/spec/CTS2/1.0/MapVersion"
    xmlns:stmt="http://schema.omg.org/spec/CTS2/1.0/Statement"
    xmlns:valueset="http://schema.omg.org/spec/CTS2/1.0/ValueSet"
    xmlns:valuesetdefinition="http://schema.omg.org/spec/CTS2/1.0/ValueSetDefinition"
    xmlns:updates="http://schema.omg.org/spec/CTS2/1.0/Updates" 
    
    xmlns:core1.1="http://www.omg.org/spec/CTS2/1.1/Core"
    xmlns:association1.1="http://www.omg.org/spec/CTS2/1.1/Association"
    xmlns:codesystem1.1="http://www.omg.org/spec/CTS2/1.1/CodeSystem"
    xmlns:codesystemversion1.1="http://www.omg.org/spec/CTS2/1.1/CodeSystemVersion"
    xmlns:conceptdomain1.1="http://www.omg.org/spec/CTS2/1.1/ConceptDomain"
    xmlns:conceptdomainbinding1.1="http://www.omg.org/spec/CTS2/1.1/ConceptDomainBinding"
    xmlns:entity1.1="http://www.omg.org/spec/CTS2/1.1/Entity" 
    xmlns:map1.1="http://www.omg.org/spec/CTS2/1.1/MapCatalog"
    xmlns:mapversion1.1="http://www.omg.org/spec/CTS2/1.1/MapVersion"
    xmlns:stmt1.1="http://www.omg.org/spec/CTS2/1.1/Statement"
    xmlns:valueset1.1="http://www.omg.org/spec/CTS2/1.1/ValueSet"
    xmlns:valuesetdefinition1.1="http://www.omg.org/spec/CTS2/1.1/ValueSetDefinition"
    xmlns:updates1.1="http://www.omg.org/spec/CTS2/1.1/Updates">
    
    <!-- This stylesheet provides a formal, executable specification for transforming CTS2 1.1 content
         into the equivalent CTS2 1.0 representation -->

    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="testing" select="false()"/>


    <!-- =========================================
        Issue #90 - Namespace transformation 
         Part 1: Convert the schemaLocation if present
            Covered in CTS2ConversionUtils.xsl on match schemaLocation
         Part 2: Change all the actual namespaces.
            Covered in CTS2ConversionUtils.xsl generic match template -->
    
    <xsl:variable name="sourceNamespace">http://www.omg.org/spec/CTS2/1.1/</xsl:variable>
    <!-- Change this to the appropriate spot on the OMG server once the spec is accepted and published -->
    <xsl:param name="sourceSchemaLocation">http://informatics.mayo.edu/cts2/spec/CTS2/1.1/</xsl:param>
    <xsl:variable name="targetNamespace">http://schema.omg.org/spec/CTS2/1.0/</xsl:variable>
    <xsl:variable name="targetSchemaLocation">http://www.omg.org/spec/cts2/201206/</xsl:variable>
    
    <xsl:include href="CTS2ConversionUtils.xsl"/>
    
    <!-- =========================================
        Issue #118 - AssociationDirectory needs associationID
            associationID has to be removed when transforming to 1.0
        Issue #120 - Include depth indicator in AssociationGraph
            depth has to be removed when transforming to 1.0
        (no issue?) - AssociationGraph needs associationID
             associationID has to be removed when transforming to 1.0
        Issue #156 - AssociationDirectory needs derivation
            derivation has to be removed when transforming to 1.0
        ========================================== -->
    <xsl:template match="association1.1:entry">
        <xsl:choose>
            <xsl:when test="parent::association1.1:AssociationGraph">
                <xsl:element name="{local-name()}" namespace="{$nsmap/association}">
                    <xsl:apply-templates select="@*[name() != 'associationID' and name() != 'depth']"/>
                    <xsl:apply-templates select="node() "/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{local-name()}" namespace="{$nsmap/association}">
                    <xsl:choose>
                        <xsl:when test="parent::association1.1:AssociationDirectory">
                            <xsl:apply-templates select="@*[name() != 'associationID' and name() != 'derivation']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="@*"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="node() "/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- =========================================
        Issue #119 - associationID should optional and not have a deafult
             If absent, add it with a generated value.  This impacts Association, AssociationMsg and AssociationList
        Issue #157 - derivation should be optional and not have a default
             If absent, add one with the default of ASSERTED
        ========================================== -->
    <xsl:template match="association1.1:Association | association1.1:association">
        <xsl:call-template name="addAssociationIdandDerivation"/>
    </xsl:template>

    <xsl:template name="addAssociationIdandDerivation">
        <xsl:element name="{local-name()}" namespace="{$nsmap/association}">
            <xsl:apply-templates select="@*"/>
            <xsl:if test="not(@associationID)">
                <xsl:attribute name="associationID">
                    <xsl:choose>
                        <xsl:when test="$testing">(GUID)</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('urn:uuid:',document('http://informatics.mayo.edu/cts2/services/bioportal-rdf/uuid'))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@derivation)">
                <xsl:attribute name="derivation">ASSERTED</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node() "/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="association1.1:AssociationList">
        <xsl:element name="{local-name()}" namespace="{$nsmap/association}">
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="local-name() = 'entry'">
                        <xsl:call-template name="addAssociationIdandDerivation"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>



    <!-- =========================================
        Issue #121 - add optional 'hasOntologyLanguage' and 'includes' to CodeSystemCatalogEntry
               Need to remove from CTS2 1.1 if present
        ========================================== -->
    <xsl:template match="codesystem1.1:hasOntologyLanguage"/>
    <xsl:template match="codesystem1.1:includes"/>


    <!-- =========================================
        Issue #129 - additional options for Entity Read Query
            codeSystemRole added to DescriptionInCodeSystem and EntityDescriptionBase
            DescriptionInCodeSystem - in entityReference (knownEntityDescription)
                                    - AnonymousEntityReference
                                    - NamedEntityReference
            all are called core1.1:knownEntityDescription
        ========================================== -->
    <xsl:template match="core1.1:knownEntityDescription">
        <xsl:element name="{local-name()}" namespace="{$nsmap/core}">
            <xsl:apply-templates select="node() | @*[name()!='codeSystemRole'] "/>
        </xsl:element>
    </xsl:template>
    <xsl:template
        match="entity1.1:namedEntity | entity1.1:anonymousEntity | entity1.1:classDescription | entity1.1:dataTypeDescription |
                         entity1.1:predicateDescription | entity1.1:objectPropertyDescription | entity1.1:dataPropertyDescription |
                         entity1.1:annotationPropertyDescription | entity1.1:namedIndividual | entity1.1:anonymousIndividual">
        <xsl:element name="{local-name()}" namespace="{$nsmap/entity}">
            <xsl:apply-templates select="node() | @*[name()!='codeSystemRole'] "/>
        </xsl:element>
    </xsl:template>

    <!-- =========================================
        Issue #134 - no way to get to current resolution from a value set
            Need to remove currentResolution node when converting back to 1.0
        ========================================== -->
    <xsl:template match="valueset1.1:currentResolution">
        <xsl:choose>
            <xsl:when test="parent::valueset1.1:ValueSetCatalogEntry"/>
            <xsl:when test="parent::valueset1.1:valueSetCatalogEntry"/>
            <xsl:otherwise>
                <xsl:call-template name="changeNamespace"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- =========================================
        Issue #136 - parents URI needed in EntityDescription
            Remove parents when converting back to 1.0
        ========================================== -->
    <xsl:template match="entity1.1:parents"/>

    <!-- =========================================
        Issue #137 - extensible directories, which are constraints on lists
        Constraints are ignored in CTS2 1.0, so client needs to deal with extra if it shows up
        ========================================== -->


    <!-- =========================================
        Issue #138 - document URI shouldn't be mandatory in resource description
            Add a document URI that matches about URI if not present
        Issue #140 - sourceAndNotation made optional
            Add a dummy sourceAndNotation if missing
        ========================================== -->
    <xsl:template
        match="codesystemversion1.1:CodeSystemVersionCatalogEntry | codesystemversion1.1:codeSystemVersionCatalogEntry">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/codesystemversion"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="entry[ancestor::codesystemversion1.1:CodeSystemVersionCatalogEntryList]">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/codesystemversion"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="mapversion1.1:MapVersion | mapversion1.1:mapVersion">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/mapversion"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="entry[ancestor::mapversion1.1:MapVersionList]">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/mapversion"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="valuesetdefinition1.1:ValueSetDefinition | valuesetdefinition1.1:valueSetDefinition">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/valuesetdefinition"/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="entry[ancestor::valuesetdefinition1.1:ValueSetDefinitionList]">
        <xsl:call-template name="addSourceAndNotation">
            <xsl:with-param name="ns" select="$nsmap/valuesetdefinition"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="addSourceAndNotation">
        <xsl:param name="ns"/>
        <xsl:if test="not(@documentURI)">
            <xsl:attribute name="documentURI">
                <xsl:value-of select="@about"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="core1.1:sourceAndNotation">
                <xsl:call-template name="changeNamespace"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="elements-before"
                    select="core1.1:status|core1.1:changeDescription|core1.1:keyword|core1.1:resourceType|
                                                            core1.1:resourceSynopsis|core1.1:additionalDocumentation|core1.1:sourceAndRole|
                                                            core1.1:rights"/>
                <xsl:element name="{local-name()}" namespace="{$ns}">
                    <!-- Comments and processing instructions can't be kept in order so we drop them -->
                    <xsl:apply-templates select="$elements-before | @* "/>
                    <xsl:element name="sourceAndNotation" namespace="{$nsmap/core}"/>
                    <!-- Implement 1.0 version of <xsl:apply-templates select="* except $elements-before"/>-->
                    <xsl:for-each select="*">
                        <xsl:if test="not($elements-before[name()=name(current()/.)])">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>

                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- =========================================
        Issue #122- MapEntry MapFrom and MapTo elements need optional description
        Issue #141 - referencedEntity in value set definition should have optional description
        Issue #143 - URIAndEntityName should have an optional description
            Strip designation from all URIAndEntityName entries that weren't EntitySynopsis in 1.0
            Instead of listing all of the places with URIAndEntityName, it is easier to strip 
            designations from everywhere thowe whose ancestor is IterableResolvedValueSet or ResolvedValueSet           
        ========================================== -->
    <xsl:template match="core1.1:designation">
        <xsl:choose>
            <xsl:when
                test="ancestor::valuesetdefinition1.1:resolvedValueSet or ancestor::valuesetdefinition1.1:ResolvedValueSet or ancestor::valuesetdefinition1.1:IteratableResolvedValueSet">
                <xsl:call-template name="changeNamespace"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- =========================================
        Issue #147 - ResolvedValueSet.member changed to ResolvedValueSet.entry 
            Have to switch back to member in 1.0
        ========================================== -->
    <xsl:template match="valuesetdefinition1.1:entry">
        <xsl:choose>
            <xsl:when
                test="ancestor::valuesetdefinition1.1:ResolvedValueSet or ancestor::valuesetdefinition1.1:ResolvedValueSetMsg">
                <xsl:element name="member" namespace="{$nsmap/valuesetdefinition}">
                    <xsl:apply-templates select="node() | @*"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="changeNamespace"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



</xsl:stylesheet>

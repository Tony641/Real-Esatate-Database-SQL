CREATE DATABASE RealEstateDB;
use RealEstateDB;

CREATE TABLE Agent (
    AgentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    ProfileDescription TEXT,
    HireDate DATE DEFAULT GETDATE(),
    Active BIT DEFAULT 1
);

CREATE TABLE Client (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    ClientType VARCHAR(10) CHECK (ClientType IN ('Buyer', 'Seller')) NOT NULL,
    RegistrationDate DATETIME DEFAULT GETDATE()
);

-- Create Property Table
CREATE TABLE Property (
    PropertyID INT PRIMARY KEY IDENTITY(1,1),
    AddressLine1 VARCHAR(255) NOT NULL,
    AddressLine2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(50) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    PropertyType VARCHAR(50) CHECK (PropertyType IN ('Residential', 'Commercial', 'Land', 'Other')) NOT NULL,
    Bedrooms INT,
    Bathrooms DECIMAL(3,1),
    SquareFootage INT,
    YearBuilt INT,
    Description TEXT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_Bedrooms CHECK (Bedrooms >= 0),
    CONSTRAINT CHK_Bathrooms CHECK (Bathrooms >= 0),
    CONSTRAINT CHK_SquareFootage CHECK (SquareFootage > 0),
    CONSTRAINT CHK_YearBuilt CHECK (YearBuilt > 1800)
);
ALTER TABLE Property
ADD Location geography;
GO


CREATE TABLE Listing (
    ListingID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    AgentID INT NOT NULL,
    ListPrice DECIMAL(18,2) NOT NULL,
    ListingDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) CHECK (Status IN ('Active', 'Sold', 'Expired', 'Pending')) NOT NULL,
    CommissionRate DECIMAL(5,2),
    Remarks TEXT,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT CHK_ListPrice CHECK (ListPrice > 0)
);

CREATE TABLE Sale (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    BuyerClientID INT NOT NULL,
    SellerClientID INT NOT NULL,
    AgentID INT NOT NULL,
    SalePrice DECIMAL(18,2) NOT NULL,
    SaleDate DATETIME DEFAULT GETDATE(),
    ClosingDate DATETIME,
    CommissionAmount DECIMAL(18,2),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (BuyerClientID) REFERENCES Client(ClientID),
    FOREIGN KEY (SellerClientID) REFERENCES Client(ClientID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT CHK_SalePrice CHECK (SalePrice > 0)
);


CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    AgentID INT NOT NULL,
    ClientID INT NOT NULL,
    AppointmentDateTime DATETIME NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Purpose VARCHAR(255),
    Notes TEXT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);

-- Create Appraisal Table
CREATE TABLE Appraisal (
    AppraisalID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    AgentID INT NOT NULL,
    AppraisalValue DECIMAL(18,2) NOT NULL,
    AppraisalDate DATETIME DEFAULT GETDATE(),
    Notes TEXT,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT CHK_AppraisalValue CHECK (AppraisalValue > 0)
);


CREATE TABLE PropertyImage (
    ImageID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    ImageURLs NVARCHAR(MAX) NOT NULL,  -- JSON array to store multiple image URLs
    Description VARCHAR(255),
    UploadDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);

CREATE INDEX IDX_Property_Location ON Property(City, State);
CREATE INDEX IDX_Listing_Status ON Listing(Status);
CREATE INDEX IDX_Client_Email ON Client(Email);
CREATE INDEX IDX_Sale_Date ON Sale(SaleDate);


CREATE TABLE PropertyFeature (
    FeatureID INT PRIMARY KEY IDENTITY(1,1),
    FeatureName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT
);

CREATE TABLE PropertyFeatureMapping (
    PropertyID INT NOT NULL,
    FeatureID INT NOT NULL,
    CONSTRAINT PK_PropertyFeatureMapping PRIMARY KEY (PropertyID, FeatureID),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (FeatureID) REFERENCES PropertyFeature(FeatureID)
);

CREATE TABLE Offer (
    OfferID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    BuyerClientID INT NOT NULL,
    OfferAmount DECIMAL(18,2) NOT NULL,
    OfferDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) CHECK (Status IN ('Pending', 'Accepted', 'Rejected', 'Countered')) NOT NULL,
    Comments TEXT,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (BuyerClientID) REFERENCES Client(ClientID),
    CONSTRAINT CHK_OfferAmount CHECK (OfferAmount > 0)
);

CREATE TABLE OpenHouse (
    OpenHouseID INT PRIMARY KEY IDENTITY(1,1),
    ListingID INT NOT NULL,
    AgentID INT NOT NULL,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Comments TEXT,
    FOREIGN KEY (ListingID) REFERENCES Listing(ListingID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID)
);

CREATE TABLE Rental (
    RentalID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    AgentID INT NOT NULL,
    RentalPrice DECIMAL(18,2) NOT NULL,
    LeaseTerm VARCHAR(50) NOT NULL,  -- e.g., '6 months', '1 year'
    AvailableFrom DATETIME NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Available', 'Rented', 'Pending')) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID),
    CONSTRAINT CHK_RentalPrice CHECK (RentalPrice > 0)
);

CREATE TABLE Document (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    RelatedEntityType VARCHAR(50) NOT NULL,  -- e.g., 'Property', 'Listing', 'Sale'
    RelatedEntityID INT NOT NULL,
    DocumentType VARCHAR(50) NOT NULL,        -- e.g., 'Contract', 'Disclosure', 'Inspection Report'
    FilePath NVARCHAR(255) NOT NULL,
    UploadDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Mortgage (
    MortgageID INT PRIMARY KEY IDENTITY(1,1),
    BuyerClientID INT NOT NULL,
    PropertyID INT NOT NULL,
    Lender VARCHAR(255) NOT NULL,
    LoanAmount DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE,
    FOREIGN KEY (BuyerClientID) REFERENCES Client(ClientID),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    CONSTRAINT CHK_LoanAmount CHECK (LoanAmount > 0),
    CONSTRAINT CHK_InterestRate CHECK (InterestRate >= 0)
);

CREATE TABLE MaintenanceRequest (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    RequestDate DATETIME DEFAULT GETDATE(),
    Description TEXT NOT NULL,
    Status VARCHAR(20) CHECK (Status IN ('Open', 'In Progress', 'Completed', 'Cancelled')) NOT NULL,
    CompletionDate DATETIME,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);

CREATE TABLE Favorite (
    FavoriteID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    PropertyID INT NOT NULL,
    DateAdded DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);

CREATE TABLE Contract (
    ContractID INT PRIMARY KEY IDENTITY(1,1),
    RelatedEntityType VARCHAR(50) CHECK (RelatedEntityType IN ('Sale', 'Rental')) NOT NULL,
    RelatedEntityID INT NOT NULL,  -- ID from Sale or Rental table
    ContractDate DATETIME DEFAULT GETDATE(),
    ContractDetails TEXT,
    EffectiveDate DATE,
    ExpiryDate DATE,
    DocumentID INT,  -- Optionally link to a Document record
    FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID)
);

CREATE TABLE Vendor (
    VendorID INT PRIMARY KEY IDENTITY(1,1),
    VendorName VARCHAR(255) NOT NULL,
    ServiceType VARCHAR(100),  -- e.g., 'Inspection', 'Maintenance', 'Legal'
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(255),
    Website VARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE()
);
ALTER TABLE Sale
ADD PaymentID INT;

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    SaleID INT,  -- Link payment to a sale, if applicable
    PaymentAmount DECIMAL(18,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod VARCHAR(50),  -- e.g., 'Credit Card', 'Bank Transfer'
    PaymentStatus VARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')) NOT NULL,
    Remarks TEXT,
    FOREIGN KEY (SaleID) REFERENCES Sale(SaleID),
    CONSTRAINT CHK_PaymentAmount CHECK (PaymentAmount > 0)
);

ALTER TABLE Sale
ADD CONSTRAINT FK_Sale_Payment FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID);

CREATE TABLE UserAccount (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,  -- store a hashed password
    Role VARCHAR(50) CHECK (Role IN ('Admin', 'Agent', 'Manager', 'Staff','Client','Seller','Vendor')) NOT NULL,
  
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLogin DATETIME,
    IsActive BIT DEFAULT 1,
  
);

CREATE TABLE ActivityLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,  -- Can be NULL if system-generated
    ActivityType VARCHAR(100) NOT NULL,  -- e.g., 'Login', 'Update Listing', 'Payment Processed'
    ActivityDescription TEXT,
    ActivityDate DATETIME DEFAULT GETDATE(),
    IPAddress VARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID)
);

CREATE TABLE RentalProperty (
    RentalID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,  -- References the Property table
    RentPrice DECIMAL(18,2) NOT NULL,
    LeaseTerm INT,  -- Lease term in months
    DepositAmount DECIMAL(18,2),
    AvailableFrom DATETIME NOT NULL,
    RentStatus VARCHAR(50) CHECK (RentStatus IN ('Available', 'Rented', 'Pending')) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    CONSTRAINT CHK_RentPrice CHECK (RentPrice > 0)
);
GO

CREATE TABLE Insurance (
    InsuranceID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,  -- Link to the Property
    InsuranceCompany VARCHAR(255) NOT NULL,
    PolicyNumber VARCHAR(50) NOT NULL,
    CoverageAmount DECIMAL(18,2) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    PremiumAmount DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);
GO

CREATE TABLE Inspection (
    InspectionID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    InspectorID INT NOT NULL,  -- Vendor or user ID of the inspector
    InspectionDate DATETIME NOT NULL,
    InspectionReport TEXT,
    InspectionResult VARCHAR(50) CHECK (InspectionResult IN ('Passed', 'Failed', 'Pending')) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (InspectorID) REFERENCES Vendor(VendorID)
);
GO

CREATE TABLE PropertyTax (
    TaxID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    TaxYear INT NOT NULL,  -- The year of the property tax
    TaxAmount DECIMAL(18,2) NOT NULL,
    DueDate DATETIME NOT NULL,
    PaymentStatus VARCHAR(50) CHECK (PaymentStatus IN ('Paid', 'Pending', 'Overdue')) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);
GO

CREATE TABLE PaymentHistoryForRentAndMortage (
    PaymentHistoryID INT PRIMARY KEY IDENTITY(1,1),
    PaymentType VARCHAR(50) CHECK (PaymentType IN ('Rent', 'Mortgage')) NOT NULL,
    PropertyID INT NOT NULL,  -- Link to the Property
    PaymentAmount DECIMAL(18,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentStatus VARCHAR(50) CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')) NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);
GO

CREATE TABLE TransactionLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    EntityType VARCHAR(50)  NOT NULL, --e.g 'Agent', 'Client', 'Property', 'Sale', 'Listing' 
    EntityID INT NOT NULL,  -- ID of the affected entity (e.g., AgentID, ClientID)
    ActionType VARCHAR(50) CHECK (ActionType IN ('Insert', 'Update', 'Delete')) NOT NULL,
    ActionDetails TEXT,
    ActionDate DATETIME DEFAULT GETDATE(),
    PerformedBy INT,  -- ID of the person who performed the action (could be an Admin or System)
    FOREIGN KEY (PerformedBy) REFERENCES Agent(AgentID)  -- Assuming actions are logged by an agent
);
GO

CREATE TABLE MarketingCampaign (
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName VARCHAR(255) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    Budget DECIMAL(18,2) NOT NULL,
    CampaignType VARCHAR(50) CHECK (CampaignType IN ('Online', 'Offline', 'Email', 'TV', 'Radio')) NOT NULL,
    TargetAudience VARCHAR(255),
    Description TEXT,
    Status VARCHAR(50) CHECK (Status IN ('Active', 'Completed', 'Canceled')) NOT NULL
);
GO

CREATE TABLE Survey (
    SurveyID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    SurveyDate DATETIME DEFAULT GETDATE(),
    SurveyType VARCHAR(50) CHECK (SurveyType IN ('Property', 'Agent', 'Service')) NOT NULL,
    Response TEXT,
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);
GO

CREATE TABLE PropertyTransactionHistory (
    HistoryID INT PRIMARY KEY IDENTITY(1,1),
    PropertyID INT NOT NULL,
    ActionType VARCHAR(50) CHECK (ActionType IN ('Listed', 'Sold', 'Withdrawn')) NOT NULL,
    ActionDate DATETIME DEFAULT GETDATE(),
    ActionDetails TEXT,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID)
);
GO

CREATE TABLE Referral (
    ReferralID INT PRIMARY KEY IDENTITY(1,1),
    ReferringClientID INT,
    ReferredClientID INT,
    ReferralDate DATETIME DEFAULT GETDATE(),
    ReferralStatus VARCHAR(50) CHECK (ReferralStatus IN ('Pending', 'Completed', 'Rejected')) NOT NULL,
    ReferralBonus DECIMAL(18,2),  -- If applicable
    FOREIGN KEY (ReferringClientID) REFERENCES Client(ClientID),
    FOREIGN KEY (ReferredClientID) REFERENCES Client(ClientID)
);
GO







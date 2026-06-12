/*
 * BCMCH Demo - Sample Data Loader (anonymous Apex)
 * Run:  sf apex run -f scripts/apex/sampleData.apex
 * Creates Departments, Doctors, Patients (Lead__c), Appointments, Calls and HCP Referrals.
 * Re-runnable: removes previously loaded demo rows (tagged via well-known names) before inserting.
 */

// ---------- Cleanup previous demo rows (best-effort) ----------
delete [SELECT Id FROM HCP_Referral__c];
delete [SELECT Id FROM Appointment__c WHERE Doctor__r.Name LIKE 'Dr. %'];
delete [SELECT Id FROM Call__c WHERE From_Number__c LIKE '+91 %'];
delete [SELECT Id FROM Lead__c WHERE Hospital_Number__c LIKE 'BCM-%'];
delete [SELECT Id FROM Doctor__c WHERE Name LIKE 'Dr. %'];
delete [SELECT Id FROM Department__c WHERE Name IN ('Cardiology','Oncology','Nephrology','Neurology','Orthopedics','Pediatrics','ENT','General Medicine')];

Date today = Date.today();

// ---------- Departments ----------
List<String> deptNames = new List<String>{'Cardiology','Oncology','Nephrology','Neurology','Orthopedics','Pediatrics','ENT','General Medicine'};
List<Department__c> depts = new List<Department__c>();
for (String d : deptNames) depts.add(new Department__c(Name = d));
insert depts;
Map<String, Id> deptId = new Map<String, Id>();
for (Department__c d : depts) deptId.put(d.Name, d.Id);

// ---------- Doctors ----------  (Specialization__c must use existing picklist values)
List<Doctor__c> docs = new List<Doctor__c>{
  new Doctor__c(Name='Dr. Thomas George', Department__c=deptId.get('Cardiology'),     Specialization__c='Cardio',        Qualification__c='MD',   Avaliability__c='Daily 10 AM - 2 PM', Experience__c=18, Email__c='thomas.george@bcmch.org', Mobile__c='+91 9847012301'),
  new Doctor__c(Name='Dr. Leela Krishnan', Department__c=deptId.get('Cardiology'),     Specialization__c='Cardio',        Qualification__c='MD',   Avaliability__c='Every Monday',       Experience__c=12, Email__c='leela.k@bcmch.org',       Mobile__c='+91 9847012302'),
  new Doctor__c(Name='Dr. Anjali Nair',    Department__c=deptId.get('Oncology'),       Specialization__c='Oncology',      Qualification__c='MD',   Avaliability__c='Daily 10 AM - 2 PM', Experience__c=15, Email__c='anjali.nair@bcmch.org',   Mobile__c='+91 9847012303'),
  new Doctor__c(Name='Dr. Rahul Menon',    Department__c=deptId.get('Nephrology'),     Specialization__c='Nephrologists', Qualification__c='MD',   Avaliability__c='Daily 5 PM - 7 PM',  Experience__c=10, Email__c='rahul.menon@bcmch.org',   Mobile__c='+91 9847012304'),
  new Doctor__c(Name='Dr. Priya Varghese', Department__c=deptId.get('Neurology'),      Specialization__c='Neuro',         Qualification__c='MD',   Avaliability__c='Every Tuesday',      Experience__c=14, Email__c='priya.v@bcmch.org',       Mobile__c='+91 9847012305'),
  new Doctor__c(Name='Dr. Suresh Kumar',   Department__c=deptId.get('Orthopedics'),    Specialization__c='Ortho',         Qualification__c='MBBS', Avaliability__c='Daily 10 AM - 2 PM', Experience__c=20, Email__c='suresh.kumar@bcmch.org',  Mobile__c='+91 9847012306'),
  new Doctor__c(Name='Dr. Meera Pillai',   Department__c=deptId.get('Pediatrics'),     Specialization__c='Paediatrician', Qualification__c='MD',   Avaliability__c='Full Time',          Experience__c=9,  Email__c='meera.pillai@bcmch.org', Mobile__c='+91 9847012307'),
  new Doctor__c(Name='Dr. John Mathew',    Department__c=deptId.get('ENT'),            Specialization__c='ENT',           Qualification__c='FRCS', Avaliability__c='Every Wednesday',    Experience__c=11, Email__c='john.mathew@bcmch.org',   Mobile__c='+91 9847012308'),
  new Doctor__c(Name='Dr. Lakshmi Iyer',   Department__c=deptId.get('General Medicine'),Specialization__c='Physician',    Qualification__c='MD',   Avaliability__c='Full Time',          Experience__c=16, Email__c='lakshmi.iyer@bcmch.org', Mobile__c='+91 9847012309')
};
insert docs;
Map<String, Id> docId = new Map<String, Id>();
for (Doctor__c d : docs) docId.put(d.Name, d.Id);

// ---------- Patients (Lead__c) ----------
List<Lead__c> pts = new List<Lead__c>{
  new Lead__c(Name='Rahul', Last_Name__c='Menon', Hospital_Number__c='BCM-10231', Age__c=45, Gender__c='Male', Blood_Group__c='B+', Mobile__c='+91 9876543210', Email__c='rahul.m@example.com', Status__c='Treatment', Type__c='Direct', Doctor__c=docId.get('Dr. Thomas George'), Occupation__c='Teacher', Patient_Category__c='Chronic', Preferred_Contact__c='Phone', Diagnosis__c='Hypertension with Type-2 Diabetes; under cardiology follow-up.', Follow_up_Date__c=today.addDays(6), Last_Visit_Date__c=today.addDays(-10), Last_Admit_Date__c=today.addDays(-15), Registration_Date__c=Date.newInstance(2024,1,12), Last_Engagement_Date__c=today, Lifetime_Value__c=185000),
  new Lead__c(Name='Anjali', Last_Name__c='Nair', Hospital_Number__c='BCM-10876', Age__c=38, Gender__c='Female', Blood_Group__c='O+', Mobile__c='+91 9988776655', Email__c='anjali.nair@example.com', Status__c='Follow-up', Type__c='Second Opinion', Doctor__c=docId.get('Dr. Anjali Nair'), Occupation__c='Software Engineer', Patient_Category__c='Regular', Preferred_Contact__c='WhatsApp', Diagnosis__c='Post-operative oncology follow-up; quarterly screening.', Follow_up_Date__c=today.addDays(13), Last_Visit_Date__c=today.addDays(-12), Registration_Date__c=Date.newInstance(2023,3,4), Last_Engagement_Date__c=today, Lifetime_Value__c=240000),
  new Lead__c(Name='Thomas', Last_Name__c='George', Hospital_Number__c='BCM-11204', Age__c=60, Gender__c='Male', Blood_Group__c='A+', Mobile__c='+91 9123456780', Email__c='thomas.g@example.com', Status__c='New', Type__c='Direct', Doctor__c=docId.get('Dr. Suresh Kumar'), Occupation__c='Retired', Patient_Category__c='New', Preferred_Contact__c='Phone', Diagnosis__c='Knee osteoarthritis; orthopedic evaluation pending.', Follow_up_Date__c=today.addDays(3), Registration_Date__c=today.addDays(-11), Last_Engagement_Date__c=today, Lifetime_Value__c=95000),
  new Lead__c(Name='Fathima', Last_Name__c='Beevi', Hospital_Number__c='BCM-11890', Age__c=29, Gender__c='Female', Blood_Group__c='AB+', Mobile__c='+91 9087611223', Email__c='fathima.b@example.com', Status__c='Treatment', Type__c='Direct', Doctor__c=docId.get('Dr. Meera Pillai'), Occupation__c='Homemaker', Patient_Category__c='VIP', Preferred_Contact__c='SMS', Diagnosis__c='Maternity care; antenatal follow-up.', Follow_up_Date__c=today.addDays(8), Last_Visit_Date__c=today.addDays(-6), Last_Admit_Date__c=today.addDays(-10), Registration_Date__c=Date.newInstance(2022,8,15), Last_Engagement_Date__c=today.addDays(-1), Lifetime_Value__c=360000),
  new Lead__c(Name='Joseph', Last_Name__c='Kurian', Hospital_Number__c='BCM-12055', Age__c=52, Gender__c='Male', Blood_Group__c='O+', Mobile__c='+91 9447088990', Email__c='joseph.k@example.com', Status__c='Follow-up', Type__c='Direct', Doctor__c=docId.get('Dr. Rahul Menon'), Occupation__c='Businessman', Patient_Category__c='Regular', Preferred_Contact__c='Phone', Diagnosis__c='Chronic kidney disease; dialysis schedule monitoring.', Follow_up_Date__c=today.addDays(2), Last_Visit_Date__c=today.addDays(-4), Registration_Date__c=Date.newInstance(2023,11,20), Last_Engagement_Date__c=today.addDays(-1), Lifetime_Value__c=410000),
  new Lead__c(Name='Sara', Last_Name__c='Abraham', Hospital_Number__c='BCM-12190', Age__c=34, Gender__c='Female', Blood_Group__c='A-', Mobile__c='+91 9846551122', Email__c='sara.a@example.com', Status__c='Converted', Type__c='Second Opinion', Doctor__c=docId.get('Dr. Priya Varghese'), Occupation__c='Banker', Patient_Category__c='Regular', Preferred_Contact__c='Email', Diagnosis__c='Migraine management; neurology review.', Follow_up_Date__c=today.addDays(20), Last_Visit_Date__c=today.addDays(-20), Registration_Date__c=Date.newInstance(2024,5,2), Last_Engagement_Date__c=today.addDays(-3), Lifetime_Value__c=72000)
};
insert pts;
Map<String, Id> ptId = new Map<String, Id>();
for (Lead__c p : pts) ptId.put(p.Hospital_Number__c, p.Id);

// ---------- Appointments ----------
List<Appointment__c> appts = new List<Appointment__c>();
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Thomas George'), Patient__c=ptId.get('BCM-10231'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-2), Time.newInstance(10,0,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(-2), Time.newInstance(10,30,0,0)), Status__c='Completed'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Thomas George'), Patient__c=ptId.get('BCM-10231'), Start_Date_Time__c=Datetime.newInstance(today.addDays(6), Time.newInstance(11,0,0,0)),  End_Date_Time__c=Datetime.newInstance(today.addDays(6), Time.newInstance(11,30,0,0)), Status__c='Booked'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Anjali Nair'),    Patient__c=ptId.get('BCM-10876'), Start_Date_Time__c=Datetime.newInstance(today.addDays(13), Time.newInstance(12,0,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(13), Time.newInstance(12,30,0,0)), Status__c='Booked'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Suresh Kumar'),   Patient__c=ptId.get('BCM-11204'), Start_Date_Time__c=Datetime.newInstance(today.addDays(3), Time.newInstance(9,0,0,0)),   End_Date_Time__c=Datetime.newInstance(today.addDays(3), Time.newInstance(9,30,0,0)),  Status__c='Booked'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Meera Pillai'),   Patient__c=ptId.get('BCM-11890'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-6), Time.newInstance(16,0,0,0)),End_Date_Time__c=Datetime.newInstance(today.addDays(-6), Time.newInstance(16,30,0,0)),Status__c='Paid'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Meera Pillai'),   Patient__c=ptId.get('BCM-11890'), Start_Date_Time__c=Datetime.newInstance(today.addDays(8), Time.newInstance(16,0,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(8), Time.newInstance(16,30,0,0)), Status__c='Booked'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Rahul Menon'),    Patient__c=ptId.get('BCM-12055'), Start_Date_Time__c=Datetime.newInstance(today.addDays(2), Time.newInstance(17,0,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(2), Time.newInstance(17,30,0,0)), Status__c='Booked'));
appts.add(new Appointment__c(Doctor__c=docId.get('Dr. Priya Varghese'), Patient__c=ptId.get('BCM-12190'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-20), Time.newInstance(11,0,0,0)),End_Date_Time__c=Datetime.newInstance(today.addDays(-20), Time.newInstance(11,30,0,0)),Status__c='Completed'));
insert appts;

// ---------- Calls ----------
List<Call__c> calls = new List<Call__c>();
calls.add(new Call__c(Agent_Name__c='Anil',  Call_Type__c='Inbound',  Call_Status__c='Completed', Duration_seconds__c=252, From_Number__c='+91 9876543210', To_Number__c='+91 4692730000', Patient__c=ptId.get('BCM-10231'), Room__c=docId.get('Dr. Thomas George'), Start_Date_Time__c=Datetime.newInstance(today, Time.newInstance(10,32,0,0)), End_Date_Time__c=Datetime.newInstance(today, Time.newInstance(10,36,12,0))));
calls.add(new Call__c(Agent_Name__c='Kumar', Call_Type__c='Outbound', Call_Status__c='Completed', Duration_seconds__c=165, From_Number__c='+91 4692730000', To_Number__c='+91 9988776655', Patient__c=ptId.get('BCM-10876'), Start_Date_Time__c=Datetime.newInstance(today, Time.newInstance(9,58,0,0)), End_Date_Time__c=Datetime.newInstance(today, Time.newInstance(10,0,45,0))));
calls.add(new Call__c(Agent_Name__c='Harish',Call_Type__c='Inbound',  Call_Status__c='Missed',    Duration_seconds__c=0,   From_Number__c='+91 9123456780', To_Number__c='+91 4692730000', Patient__c=ptId.get('BCM-11204'), Start_Date_Time__c=Datetime.newInstance(today, Time.newInstance(9,10,0,0)), End_Date_Time__c=Datetime.newInstance(today, Time.newInstance(9,10,0,0))));
calls.add(new Call__c(Agent_Name__c='Shebin',Call_Type__c='Outbound', Call_Status__c='Completed', Duration_seconds__c=363, From_Number__c='+91 4692730000', To_Number__c='+91 9087611223', Patient__c=ptId.get('BCM-11890'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(15,20,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(15,26,3,0))));
calls.add(new Call__c(Agent_Name__c='Manu',  Call_Type__c='Inbound',  Call_Status__c='Completed', Duration_seconds__c=201, From_Number__c='+91 9447088990', To_Number__c='+91 4692730000', Patient__c=ptId.get('BCM-12055'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(11,5,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(11,8,21,0))));
calls.add(new Call__c(Agent_Name__c='Sony',  Call_Type__c='Inbound',  Call_Status__c='Patient busy', Duration_seconds__c=0, From_Number__c='+91 9846551122', To_Number__c='+91 4692730000', Patient__c=ptId.get('BCM-12190'), Start_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(14,2,0,0)), End_Date_Time__c=Datetime.newInstance(today.addDays(-1), Time.newInstance(14,2,30,0))));
insert calls;

// ---------- HCP Referrals ----------
List<HCP_Referral__c> refs = new List<HCP_Referral__c>{
  new HCP_Referral__c(Referring_Doctor_Name__c='Dr. Sajan Thomas (Caritas Hospital)', Referred_To_Doctor__c=docId.get('Dr. Thomas George'), Patient__c=ptId.get('BCM-10231'), Specialization__c='Cardiology', Status__c='New',          Referral_Date__c=today.addDays(-2), Follow_up_Date__c=today.addDays(5), Reason__c='Suspected coronary artery disease, needs angiography review.'),
  new HCP_Referral__c(Referring_Doctor_Name__c='Dr. Maya Pillai (Lakeshore)',         Referred_To_Doctor__c=docId.get('Dr. Anjali Nair'),    Patient__c=ptId.get('BCM-10876'), Specialization__c='Oncology',   Status__c='Scheduled',    Referral_Date__c=today.addDays(-4), Follow_up_Date__c=today.addDays(2), Reason__c='Second opinion for post-op oncology follow-up.'),
  new HCP_Referral__c(Referring_Doctor_Name__c='City Clinic',                          Referred_To_Doctor__c=docId.get('Dr. Suresh Kumar'),   Patient__c=ptId.get('BCM-11204'), Specialization__c='Orthopedics',Status__c='Completed',    Referral_Date__c=today.addDays(-6), Visit_Logged_Date__c=today.addDays(-5), Reason__c='Knee replacement evaluation.'),
  new HCP_Referral__c(Referring_Doctor_Name__c='Dr. Rajan Nair',                        Referred_To_Doctor__c=docId.get('Dr. Rahul Menon'),    Patient__c=ptId.get('BCM-12055'), Specialization__c='Nephrology', Status__c='Visit Logged', Referral_Date__c=today.addDays(-8), Visit_Logged_Date__c=today.addDays(-7), Reason__c='CKD management and dialysis planning.'),
  new HCP_Referral__c(Referring_Doctor_Name__c='Holy Family Hospital',                  Referred_To_Doctor__c=docId.get('Dr. Priya Varghese'), Patient__c=ptId.get('BCM-12190'), Specialization__c='Neurology',  Status__c='Completed',    Referral_Date__c=today.addDays(-11), Visit_Logged_Date__c=today.addDays(-10), Reason__c='Chronic migraine evaluation.'),
  new HCP_Referral__c(Referring_Doctor_Name__c='Dr. Sajan Thomas (Caritas Hospital)',  Referred_To_Doctor__c=docId.get('Dr. Leela Krishnan'), Patient__c=ptId.get('BCM-11890'), Specialization__c='Cardiology', Status__c='New',          Referral_Date__c=today.addDays(-1), Follow_up_Date__c=today.addDays(6), Reason__c='Maternal cardiac screening.')
};
insert refs;

System.debug('BCMCH demo data loaded: ' + depts.size() + ' departments, ' + docs.size() + ' doctors, ' + pts.size() + ' patients, ' + appts.size() + ' appointments, ' + calls.size() + ' calls, ' + refs.size() + ' referrals.');

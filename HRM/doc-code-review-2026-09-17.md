# Đối chiếu tài liệu Google Drive với source HRM

Ngày đối chiếu: 17/09/2026. Source: `D:\Works\HRM`, HEAD `43379e2c` và trạng thái workspace tại lúc đọc.

Đối chiếu 21 tài liệu chức năng bản hiện hành (01–21) trong thư mục được cung cấp. Không đọc/đánh giá file 00 Tổng quan. Thư mục “HRM - Lịch sử thay đổi” chứa 13 bản cũ: đã kiểm kê, không coi nội dung bản lưu trữ khác code mới là lỗi phải sửa. Các hướng dẫn dưới đây áp dụng cho bản hiện hành ở thư mục chính.

Có **44 nhóm sai lệch hoặc nội dung cần bổ sung**, gồm luồng nghiệp vụ, điều kiện thao tác, quyền, enum và thiết kế dữ liệu. Mỗi mục nêu vị trí tìm trong tài liệu, khác biệt đã đối chiếu và cách sửa.

Đây là đối chiếu tĩnh với source hiện có, không phải xác nhận hành vi của bản đang triển khai hoặc kiểm thử toàn bộ hệ thống. Không sửa source hay tài liệu Google Drive. Code là mốc để mô tả hiện trạng; nếu doanh nghiệp muốn giữ hành vi trong đặc tả, cần tách thành yêu cầu thay đổi code thay vì coi tài liệu đã mô tả đúng sản phẩm hiện tại.

## Những mục nên sửa trước

| File | Sai lệch có ảnh hưởng lớn |
|---|---|
| 16 – OKR | Tài liệu có phê duyệt mục tiêu/điều chỉnh; code áp dụng trực tiếp. |
| 18 – LMS | Tài liệu nói nội dung bài học luôn mới nhất; code giữ snapshot theo phiên bản phát hành. |
| 19 – Thiết bị | Tài liệu mô tả danh mục cố định/khấu hao; code quản lý DeviceType theo doanh nghiệp với CRUD. |
| 09 – Hợp đồng | Lưu tạo Nháp, phải trình ký riêng; số hợp đồng là HDLD-/PLHD-. |
| 20 – Bản tin | Đã có lưu/sửa/xóa nháp và gửi duyệt riêng. |
| 17 – Chat | Sửa tin bị giới hạn 30 phút. |
| 14 – Lương | Thiếu thành phần OT/ngày lễ trong giờ công và cách chia kỳ khi đổi lương/phụ cấp. |
| 01, 03, 06, 07, 12, 15 | Enum/quyền có tên hoặc giá trị số không khớp; cần đồng bộ trước khi dùng làm chuẩn API/test. |

## Chi tiết và hướng dẫn sửa từng file

### 01. Quyền & Phân quyền v1.2

[Tài liệu Google Drive](https://docs.google.com/document/d/1ZDNi0cckwnfdcT_EO1HoTkbuG4XUh46DGlw1J1SaLiU/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/01.txt)

**01.1. Sai enum phạm vi cấp quyền**

- **Vị trí:** V.3 – `UserRoleApplyScope`.
- **Khác với code:** Tài liệu dùng `WorkingDepartments=2`, `SelectedDepartments=3`. Code dùng `UserRoleAssignmentType`: `Global=1`, `Department=2`, `WorkingDepartment=3`. Hai giá trị 2 và 3 đang mang ý nghĩa đảo nhau.
- **Cách sửa:** Thay enum bằng tên và giá trị hiện tại; đổi phần mô tả lưu phạm vi thành `UserRoleDepartmentScope.Type`; phòng ban chọn cụ thể lưu trong `UserRoleDepartment`. Không đổi dữ liệu/code để khớp enum cũ.
- **Căn cứ:** [UserRoleAssignmentType.cs:3](D:/Works/HRM/Web.Models/Enums/UserRoleAssignmentType.cs:3); [UserRoleDepartmentScope.cs:28](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/UserRoleDepartmentScope.cs:28).

**01.2. Danh sách quyền chứa mã không tồn tại**

- **Vị trí:** VI.1–2 – danh sách quyền và nhóm quyền.
- **Khác với code:** Tài liệu còn `Work.View`, `Task.Manage`, `Task.Assign`, `Schedule.Register`; danh sách `Constant.HrmPermissions` hiện tại không định nghĩa các mã này. Quyền công việc hiện có `Work.Assign`, `Work.Approve`.
- **Cách sửa:** Đồng bộ VI.1 từ `HrmPermissions`, lấy loại phạm vi từ `GetPermissionScope`; đồng bộ nhóm mặc định từ `SeedHrmGroupRolesAsync`. Xóa các mã cũ và bổ sung các quyền LMS, OKR, Asset, News đang có. Ghi rõ đây là nhóm mặc định, quyền thực tế phụ thuộc cấu hình.
- **Căn cứ:** [Constant.cs:310](D:/Works/HRM/Web.Models/SeedWork/Constant.cs:310); [WebDbContextSeed.cs:486](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Data/WebDbContextSeed.cs:486).

### 02. Cấu hình v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/11dW_3cQNBK_E86RgZMj4v8VdcBwwzfNQYNPvenrjcPU/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/02.txt)

**02.1. Cấu hình chọn workflow không còn phản ánh danh sách hiện hành**

- **Vị trí:** I.1–4, II.2–4, III – các ví dụ `ContractApprovalWorkflow`, `LeaveApprovalWorkflow`, `AdvanceApprovalWorkflow`.
- **Khác với code:** Các key này không có trong danh sách seed cấu hình hiện tại. Hợp đồng và nghỉ phép chọn `WorkflowId` trên hồ sơ nghiệp vụ; không có căn cứ để hướng dẫn chọn chúng tại Cấu hình doanh nghiệp/chi nhánh như trong wireframe.
- **Cách sửa:** Thay ví dụ bằng key thực tế như `Attendance.CheckIn.BufferMinutes`, `Attendance.CheckOut.Method`. Chuyển hướng dẫn chọn workflow sang từng module; giữ cơ chế ưu tiên chi nhánh → doanh nghiệp → mặc định cho các cấu hình thực sự có.
- **Căn cứ:** [WebDbContextSeed.cs:16](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Data/WebDbContextSeed.cs:16); [EmployeeContractService.cs:120](D:/Works/HRM/Web.Api/Services/EmployeeContractService.cs:120); [LeaveRequestService.cs:192](D:/Works/HRM/Web.Api/Services/LeaveRequestService.cs:192).

**02.2. Sai và thiếu kiểu cấu hình**

- **Vị trí:** II.1.3 – “Hệ thống hỗ trợ 4 loại cấu hình”.
- **Khác với code:** Bảng tài liệu thực tế liệt kê 5 loại và gọi kiểu chữ là `Text`. Code có 8 kiểu: `Number=0`, `Boolean=1`, `Option=2`, `Check=3`, `String=4`, `Time=5`, `Decimal=6`, `Password=7`.
- **Cách sửa:** Thay toàn bộ bảng kiểu bằng 8 giá trị trên, bổ sung giờ, số thập phân và mật khẩu; cập nhật ví dụ UI theo từng kiểu.
- **Căn cứ:** [SystemConfigValueType.cs:3](D:/Works/HRM/Web.Models/Enums/SystemConfigValueType.cs:3).

**02.3. Mẫu registry khác code**

- **Vị trí:** II.1.3 và phụ lục `ConfigDataSourceRegistry`.
- **Khác với code:** Ví dụ đầu tài liệu dùng thuộc tính `Source`; registry thực tế dùng `Data`. Các registry hiện tại chủ yếu phục vụ lịch tự động và quy tắc check-out, không chứa các nguồn workflow nêu trong ví dụ.
- **Cách sửa:** Thay đoạn class và ví dụ khởi tạo bằng cấu trúc `Key`, `SourceType`, `Data` trong `DataSource.cs`; phân biệt dữ liệu minh họa với các registry thực sự được đăng ký.
- **Căn cứ:** [DataSource.cs:59](D:/Works/HRM/Web.Models/SeedWork/DataSource.cs:59).

**02.4. Không phải mọi key đều cấu hình được theo chi nhánh**

- **Vị trí:** I.4, II.3–4 – mô tả override áp dụng cho mọi cấu hình.
- **Khác với code:** Code có CompanyOnlyKeys: Chat.MaxAttachmentSizeBytes, SocialInsurance.UnitCode, SocialInsurance.Account, SocialInsurance.Password. Các key này bị loại khỏi danh sách chi nhánh; ResolveValueAsync bỏ qua override chi nhánh.
- **Cách sửa:** Bổ sung ngoại lệ “Chỉ các key hỗ trợ phạm vi chi nhánh mới áp dụng thứ tự chi nhánh → doanh nghiệp → mặc định”; liệt kê 4 key chỉ cấp doanh nghiệp. Bổ sung mật khẩu được che khi đọc thay vì mô tả như Text thông thường.
- **Căn cứ:** [Constant.cs:175](D:/Works/HRM/Web.Models/SeedWork/Constant.cs:175); [SystemConfigurationService.cs:65](D:/Works/HRM/Web.Api/Application/SystemConfiguration/SystemConfigurationService.cs:65); [SystemConfigurationService.cs:184](D:/Works/HRM/Web.Api/Application/SystemConfiguration/SystemConfigurationService.cs:184).

### 03. Quản lý - Danh mục hệ thống v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1UgiSTP7orpY-XxpJ8-Q0DL36fa7OyQaI73ne6pthZiY/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/03.txt)

**03.1. Mô hình bảo hiểm và enum đã thay đổi**

- **Vị trí:** Phần bảo hiểm; IV – `InsuranceConfigs`; V – `InsuranceType`.
- **Khác với code:** Tài liệu mô tả `InsuranceConfigs` và `BHXH=1, BHYT=2, BHTN=3`. Code dùng nhóm bảo hiểm `InsuranceGroup`/`InsuranceGroupItem`, chia thành 5 loại với giá trị 1–5.
- **Cách sửa:** Viết lại phần danh mục bảo hiểm theo nhóm và các dòng tỷ lệ nhân viên/doanh nghiệp. Thay enum bằng `SocialRetirementSurvivorship=1`, `SocialSicknessMaternity=2`, `SocialOccupationalAccidentDisease=3`, `Unemployment=4`, `Health=5`; sửa ERD và liên kết hồ sơ nhân viên tương ứng.
- **Căn cứ:** [InsuranceGroup.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/InsuranceGroup.cs:7); [InsuranceType.cs:1](D:/Works/HRM/Web.Models/Enums/InsuranceType.cs:1).

**03.2. Sai enum loại làm việc và loại OT**

- **Vị trí:** V – `WorkType`, `OvertimeType`, `OvertimeDayType`.
- **Khác với code:** Tài liệu dùng `Fixed=1`, `Flexible=2`, nhưng code là 0 và 1. Tài liệu còn `OvertimeType.Normal/Weekend/Holiday`; code dùng Monday…Sunday=1…7, Holiday=8.
- **Cách sửa:** Thay hai enum theo code; bỏ định nghĩa `OvertimeDayType` riêng nếu đang trình bày như enum triển khai. Đồng bộ bảng hệ số OT theo từng thứ/ngày lễ.
- **Căn cứ:** [WorkType.cs:1](D:/Works/HRM/Web.Models/Enums/WorkType.cs:1); [OvertimeType.cs:1](D:/Works/HRM/Web.Models/Enums/OvertimeType.cs:1).

**03.3. Sai cách sinh mã phụ cấp**

- **Vị trí:** II – Quản lý loại phụ cấp, ràng buộc “ngẫu nhiên 5 ký tự gồm chữ và số”.
- **Khác với code:** Code gọi `GenerateNameCodeAsync` với tiền tố `PC`, lấy chữ đầu tên và thêm hậu tố khi trùng.
- **Cách sửa:** Sửa thành `PC-{chữ đầu từng từ trong tên}`; khi trùng lần đầu dùng `-1`, tiếp theo `-2`… Ví dụ tên “Ăn trưa” được xử lý theo nguyên văn hàm `GetInitials`, không cam kết tự bỏ dấu.
- **Căn cứ:** [AllowanceTypeService.cs:67](D:/Works/HRM/Web.Api/Services/AllowanceTypeService.cs:67); [CodeGenerationUtil.cs:11](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationUtil.cs:11).

### 04. Quản lý - Tổ chức Doanh nghiệp v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1a_eKnzesy6dhWnjWjJYluZVTgyQe1Xjq5Xr0miLT3qY/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/04.txt)

**04.1. Phạm vi tạo doanh nghiệp tự mâu thuẫn**

- **Vị trí:** I.4.1 so với II.2.1–2.5.
- **Khác với code:** I.4.1 đưa “Xem danh sách doanh nghiệp/Tạo doanh nghiệp” vào phạm vi HRM; phần II lại nói tạo qua CRM. Service HRM đang cung cấp xem/cập nhật doanh nghiệp hiện tại.
- **Cách sửa:** Sửa I.4.1 thành “Xem và cập nhật thông tin doanh nghiệp đang đăng nhập”; giữ việc khởi tạo doanh nghiệp ở luồng CRM.
- **Căn cứ:** [CompanyService.cs:22](D:/Works/HRM/Web.Api/Services/CompanyService.cs:22).

**04.2. Quy tắc sinh mã tổ chức không khớp**

- **Vị trí:** II.1 – ví dụ `PBCNTT`, `PBCNTT2`, bỏ từ tiền tố và bỏ dấu.
- **Khác với code:** Hàm hiện tại tạo `{prefix}-{GetInitials(name)}`, thêm `-1` khi trùng lần đầu. `GetInitials` lấy chữ đầu mọi cụm chữ/số, không có bước bỏ từ “Phòng/Chi nhánh” hoặc chuyển dấu tiếng Việt.
- **Cách sửa:** Viết lại công thức và ví dụ: với tên “Công nghệ thông tin”, mã là `PB-CNTT`, trùng thì `PB-CNTT-1`. Nêu rõ tên nhập quyết định các chữ đầu; bỏ cam kết loại từ/loại dấu nếu chưa sửa thuật toán.
- **Căn cứ:** [CodeGenerationUtil.cs:11](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationUtil.cs:11); [CompanyBranchDepartmentService.cs:471](D:/Works/HRM/Web.Api/Services/CompanyBranchDepartmentService.cs:471).

### 05. Quản lý - Ca làm việc v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/18qPUt1M9UUcWzcGzWVukHneV-S6DBbdSKS8I_BIbEcw/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/05.txt)

**05.1. Sai tiền tố và hậu tố mã ca**

- **Vị trí:** I – nguyên tắc sinh mã; II.1–2; III – form ca/lịch cố định.
- **Khác với code:** Tài liệu nói `CA + chữ đầu`, trùng bắt đầu từ 2. Code dùng tiền tố `CLV`; cả ca và lịch đều có dấu gạch nối và hậu tố trùng bắt đầu từ `-1`.
- **Cách sửa:** Đổi ví dụ ca “Ca sáng” thành `CLV-CS`, khi trùng `CLV-CS-1`; lịch “Hành chính” thành `LLV-HC`. Đồng bộ mọi ví dụ và thông báo giải thích sinh mã.
- **Căn cứ:** [CodeGenerationConstants.cs:11](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationConstants.cs:11); [WorkShiftService.cs:128](D:/Works/HRM/Web.Api/Services/WorkShiftService.cs:128); [CodeGenerationUtil.cs:11](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationUtil.cs:11).

**05.2. Thiếu điều kiện thời gian nghỉ và diễn đạt ca qua ngày chưa chặt**

- **Vị trí:** II.1 và III – kiểm tra giờ/ thời gian nghỉ.
- **Khác với code:** Tài liệu chỉ ghi thời gian nghỉ ≥0 và mô tả ca qua ngày `EndTime ≤ StartTime`. Service từ chối giờ đầu=giờ cuối, đồng thời từ chối nghỉ giữa ca ≥ tổng thời lượng ca.
- **Cách sửa:** Bổ sung: giờ bắt đầu phải khác giờ kết thúc; ca qua ngày hợp lệ có giờ kết thúc nhỏ hơn giờ bắt đầu; thời gian nghỉ phải nhỏ hơn thời lượng ca. Ví dụ ca 08:00–17:00 không nhận nghỉ 540 phút.
- **Căn cứ:** [WorkShiftService.cs:237](D:/Works/HRM/Web.Api/Services/WorkShiftService.cs:237).

### 06. Quản lý - Nhân viên v1.3

[Tài liệu Google Drive](https://docs.google.com/document/d/1Ayi2FZ7FNXfMtuJrxG2FZW0YAn6FTKIFJaTEMFuiOLw/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/06.txt)

**06.1. Sai định dạng mã nhân viên**

- **Vị trí:** II – tạo nhân viên, câu `EMP00001 (5 số cuối tự tăng)`.
- **Khác với code:** Code sinh mã theo tên bằng tiền tố `NV`, không dùng chuỗi EMP tăng dần.
- **Cách sửa:** Thay bằng `NV-{chữ đầu từng từ của họ tên}`, thêm `-1`, `-2`… khi trùng; ví dụ “Nguyễn Văn An” → `NV-NVA`.
- **Căn cứ:** [EmployeeService.cs:177](D:/Works/HRM/Web.Api/Services/EmployeeService.cs:177); [CodeGenerationUtil.cs:11](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationUtil.cs:11).

**06.2. Sai enum trạng thái nhân viên/vị trí**

- **Vị trí:** V – `EmployeeStatus`, `JobStatus`.
- **Khác với code:** Tài liệu ghi Inactive=2 và có `JobStatus` riêng; code dùng `EmployeeStatus.Inactive=0`, Active=1; `EmployeeJob.Status` cũng dùng `EmployeeStatus`.
- **Cách sửa:** Thay enum và tất cả chú thích số trong bảng/ERD. Không mô tả `JobStatus` như enum đang triển khai.
- **Căn cứ:** [EmployeeStatus.cs:1](D:/Works/HRM/Web.Models/Enums/EmployeeStatus.cs:1); [EmployeeJob.cs:26](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeJob.cs:26).

**06.3. Sai vị trí lưu chính sách phép và cấu trúc vị trí công việc**

- **Vị trí:** IV/ERD – `EmployeeEmployments`, `EmployeeJobs`.
- **Khác với code:** `LeavePolicyId`, `LeavePolicyEffectiveDate` nằm trên `Employee`, không nằm trên `EmployeeEmployment`. `EmployeeJob` hiện không có `FromDate`, `ToDate` như ERD.
- **Cách sửa:** Chuyển hai trường chính sách phép sang `Employees`; bỏ hai mốc hiệu lực khỏi ERD hiện hành của `EmployeeJobs`, mô tả hiệu lực theo Status đang có. Nếu muốn giữ quản lý theo khoảng ngày, tách thành yêu cầu phát triển.
- **Căn cứ:** [Employee.cs:21](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/Employee.cs:21); [EmployeeEmployment.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeEmployment.cs:7); [EmployeeJob.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeJob.cs:7).

**06.4. Sai liên kết bảo hiểm và tài liệu nhân viên**

- **Vị trí:** IV/ERD – `EmployeeInsurances`, `EmployeeDocuments`.
- **Khác với code:** Tài liệu dùng `InsuranceTypeId`/`InsuranceConfigs` và lưu `FileName`, `FileUrl`. Code dùng `InsuranceGroupId`; tài liệu nhân viên dùng `DocumentName`, `StoredFileId`.
- **Cách sửa:** Sửa FK bảo hiểm trỏ tới nhóm bảo hiểm; cập nhật bảng tài liệu để liên kết kho file, không mô tả FileUrl như cột dữ liệu hiện có.
- **Căn cứ:** [EmployeeInsurance.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeInsurance.cs:7); [EmployeeDocument.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeDocument.cs:7).

### 07. Quản lý - Quy trình phê duyệt v1.2

[Tài liệu Google Drive](https://docs.google.com/document/d/1ztZ0m1BdMFy85zp4rSosKcZFqkD3z9_EWyJB6wkFGn8/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/07.txt)

**07.1. Danh mục loại workflow chỉ còn một phần**

- **Vị trí:** V – `WorkflowProcessType`.
- **Khác với code:** Tài liệu dừng tại AdjustmentRequests=5; code có 17 loại, bổ sung hủy OT, LMS, bản tin, tài sản và công việc.
- **Cách sửa:** Thay nguyên enum theo file code; thêm các loại 6–17 vào phạm vi/màn chọn loại workflow. Kiểm tra các hướng dẫn liên module 10, 18, 19, 20, 21 cùng dùng một danh sách.
- **Căn cứ:** [WorkflowProcessType.cs:1](D:/Works/HRM/Web.Models/Enums/WorkflowProcessType.cs:1).

**07.2. Sai tên trường và giá trị nguồn phòng ban**

- **Vị trí:** IV/ERD `WorkflowSteps`; V `WorkflowDepartmentResolveType`.
- **Khác với code:** Code dùng `WorkflowApproverDepartmentSource.Specific=0`, `WorkingDepartment=1`; tài liệu dùng enum khác với giá trị 1/2. Các cột nguồn bước và nguồn file ký cũng khác tên.
- **Cách sửa:** Đổi `DepartmentResolveType` → `ApproverDepartmentSource`; `DepartmentSourceStepId` → `ApproverDepartmentSourceWorkflowStepId`; `DirectManagerSourceStepId` → `DirectManagerSourceWorkflowStepId`; `SignFileSourceStepId` → `SignDocumentStepId`. Đổi `Workflows.ProcessType` → `Type`; cập nhật FK và ví dụ cùng lúc.
- **Căn cứ:** [WorkflowApproverDepartmentSource.cs:3](D:/Works/HRM/Web.Models/Enums/WorkflowApproverDepartmentSource.cs:3); [WorkflowStep.cs:38](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/WorkflowStep.cs:38); [Workflow.cs:32](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/Workflow.cs:32).

### 08. Quản lý - Mẫu tài liệu v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1kwo6LWG3KhC6NgApZ-KpY9skP7pMAUK9Go6JksDXDAY/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/08.txt)

**08.1. Đoạn FileType minh họa đã lỗi thời**

- **Vị trí:** V.1.1 – `FileType`.
- **Khác với code:** Đây là đoạn đề xuất có điều kiện trong tài liệu, nhưng nếu sao chép để tích hợp sẽ sai: DocumentTemplate không phải 1 mà là 22; EmployeeDocument=23; hợp đồng là EmployeeContract=24; file workflow là WorkflowDocument=21.
- **Cách sửa:** Bỏ phương án khai báo enum mới và ghi “Dùng enum FileType chung của Web.Models”. Thay ví dụ bằng các tên/giá trị thực tế; không dùng ContractDocument, WorkflowAttachment, Other=99 như giá trị API hiện hành.
- **Căn cứ:** [FileType.cs:3](D:/Works/HRM/Web.Models/Enums/FileType.cs:3).

### 09. Quản lý - Hợp đồng v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1spQ0YPvxZVICybhixjw5N1UvYBxrmVy2rDeo6wSfVAc/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/09.txt)

**09.1. Sai trạng thái sau khi lưu hợp đồng**

- **Vị trí:** II.1.3–1.5; III.2.3 – “Sau khi lưu … Chờ duyệt/ký”.
- **Khác với code:** CreateAsync chỉ tạo entity với trạng thái mặc định Draft. SubmitSigningAsync là thao tác riêng mới chuyển sang PendingApproval; giao diện cũng tách tạo và trình ký.
- **Cách sửa:** Thay luồng bằng “Lưu → Nháp → người dùng chọn Trình ký → khởi tạo workflow → Chờ duyệt/ký”. Bổ sung thao tác trình ký ở danh sách và điều kiện sửa/xóa bản nháp.
- **Căn cứ:** [EmployeeContractService.cs:120](D:/Works/HRM/Web.Api/Services/EmployeeContractService.cs:120); [EmployeeContract.cs:22](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeContract.cs:22); [EmployeeContractDialog.razor:241](D:/Works/HRM/Web.App/Pages/Contracts/Components/EmployeeContractDialog.razor:241).

**09.2. Sai quy tắc sinh số hợp đồng**

- **Vị trí:** II.1.4; III.2.3 – `HD + số lượng hiện tại`.
- **Khác với code:** Code dùng HDLD cho hợp đồng, PLHD cho phụ lục; lấy số hậu tố lớn nhất trong các mã đúng định dạng rồi +1, độ rộng tối thiểu 2.
- **Cách sửa:** Thay bằng `HDLD-01`, `HDLD-02`… và `PLHD-01`…; nói rõ tăng theo số lớn nhất, không theo số lượng bản ghi. Ví dụ còn HDLD-01 và HDLD-09 thì mã tiếp là HDLD-10.
- **Căn cứ:** [EmployeeContractService.cs:620](D:/Works/HRM/Web.Api/Services/EmployeeContractService.cs:620); [CodeGenerationUtil.cs:90](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationUtil.cs:90); [CodeGenerationConstants.cs:13](D:/Works/HRM/Web.Api/Infrastructure/Utils/CodeGenerationConstants.cs:13).

**09.3. Điều kiện tạo phụ lục chưa đầy đủ**

- **Vị trí:** II.3.2 – chỉ cấm hợp đồng kết thúc trước hạn.
- **Khác với code:** Code chỉ nhận hợp đồng cha Active; Draft, PendingApproval, Rejected, Expired cũng không đủ điều kiện.
- **Cách sửa:** Thay bằng “Chỉ tạo phụ lục cho hợp đồng chính đang có hiệu lực (Active); không tạo phụ lục của phụ lục”.
- **Căn cứ:** [EmployeeContractService.cs:582](D:/Works/HRM/Web.Api/Services/EmployeeContractService.cs:582).

### 10. Lịch làm việc v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1_e9ZKC3FtL-L63V2CJJGYxkU4yI5Ea4OZ5ru86Y6pKU/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/10.txt)

**10.1. ERD thêm cột CompanyId không có trên lịch nhân viên**

- **Vị trí:** IV – bảng/ERD `EmployeeShifts`.
- **Khác với code:** Entity EmployeeShift không có CompanyId; phạm vi doanh nghiệp được xác định qua Employee. Không nhầm với bảng yêu cầu hủy OT có CompanyId riêng.
- **Cách sửa:** Bỏ CompanyId khỏi EmployeeShifts trong thiết kế hiện hành; mô tả lọc tenant qua Employee.CompanyId và FK EmployeeId. Giữ cột CompanyId ở các bảng khác nếu code thực sự có.
- **Căn cứ:** [EmployeeShift.cs:10](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeShift.cs:10); [EmployeeShiftRepository.cs:14](D:/Works/HRM/Web.Api/Infrastructure/Repositories/EmployeeShiftRepository.cs:14).

### 11. Chấm công v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1dhI9eGPHO0AvWp-iR09asyGGz0_MXVUnG-25E8vz9l0/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/11.txt)

**11.1. Thiếu nguồn chấm công trực tiếp từ thiết bị**

- **Vị trí:** V – `AttendanceSource`; phần nguồn log/bản ghi.
- **Khác với code:** Tài liệu chỉ có System=1, Import=2, HR=3; code thêm Device=4 và lưu nguồn check-in/check-out được chọn riêng trên AttendanceRecord.
- **Cách sửa:** Bổ sung Device=4; phân biệt log đồng bộ từ thiết bị và import file. Thêm ActualCheckInSource/ActualCheckOutSource vào thiết kế và giải thích chúng là nguồn của mốc đang được sử dụng.
- **Căn cứ:** [AttendanceSource.cs:1](D:/Works/HRM/Web.Models/Enums/AttendanceSource.cs:1); [AttendanceRecord.cs:52](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AttendanceRecord.cs:52).

**11.2. Thiếu phân biệt phút công và giờ công dùng tính lương**

- **Vị trí:** I.5 – dữ liệu tính toán; phần class AttendanceRecord.
- **Khác với code:** Tài liệu mô tả WorkingMinutes nhưng chưa thể hiện RealWorkingHour. Code RealWorkingHour trừ BreakMinutes; WorkingMinutes không trừ phần này. Tính lương lấy RealWorkingHour.
- **Cách sửa:** Thêm công thức `RealWorkingHour = ((ShiftCheckOut−ShiftCheckIn) − BreakMinutes − MissingWorkMinutes)/60`, với trường hợp thiếu mốc giờ trả 0 theo code. Không hướng dẫn lấy WorkingMinutes/60 làm giờ tính lương.
- **Căn cứ:** [AttendanceRecord.cs:127](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AttendanceRecord.cs:127); [PayrollCalculationService.cs:869](D:/Works/HRM/Web.Api/Services/PayrollCalculationService.cs:869).

### 12. Nghỉ phép v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/13zhe5yq7sip8HC6rM1LWWMIbkVo6z-wn9iBZDnIqkx4/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/12.txt)

**12.1. Sai mã loại lịch sử phép và loại tham chiếu**

- **Vị trí:** V – `LeaveHistoryType`, `LeaveRefType`.
- **Khác với code:** Các mã 1/2/3/4/6 của LeaveHistoryType không khớp. LeaveRefType trong code là LeaveRequest=1, Manual=2, System=3; không có Employee=2 hoặc LeavePolicy=4.
- **Cách sửa:** Thay LeaveHistoryType bằng AccrualMonthly=1, AccrualTenure=2, AccrualPosition=3, DeductionLeave=4, YearCarryForward=5, OpeningBalance=6; sửa mọi chú thích ERD tương ứng. Thay LeaveRefType theo code.
- **Căn cứ:** [LeaveEnums.cs:9](D:/Works/HRM/Web.Models/Enums/LeaveEnums.cs:9).

**12.2. Sai thời điểm chọn workflow và thiếu trạng thái nháp**

- **Vị trí:** II – phê duyệt; câu chọn workflow trong popup khi bấm Gửi; V `LeaveRequestStatus`.
- **Khác với code:** Form tạo đơn đã có trường Quy trình phê duyệt; CreateAsync xác thực và lưu WorkflowId cùng trạng thái Draft=0. SubmitAsync dùng hồ sơ đã lưu để gửi.
- **Cách sửa:** Chuyển bước chọn workflow sang tạo/sửa nháp; mô tả Lưu nháp → Gửi → Pending. Bổ sung Draft=0 vào enum và trạng thái UI; sửa các đoạn nói chỉ đến lúc gửi mới chọn quy trình.
- **Căn cứ:** [LeaveRequestCreateDialog.razor:98](D:/Works/HRM/Web.App/Pages/Leave/Components/LeaveRequestCreateDialog.razor:98); [LeaveRequestService.cs:192](D:/Works/HRM/Web.Api/Services/LeaveRequestService.cs:192); [LeaveEnums.cs:34](D:/Works/HRM/Web.Models/Enums/LeaveEnums.cs:34).

### 13. Thưởng phạt v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1x0SFVS8zIUJNLtxwaZ3EFVhzwpE1pP0afNzW3kZlsRc/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/13.txt)

**13.1. Phạm vi chức năng bị sao chép nhầm từ nghỉ phép**

- **Vị trí:** I.3–4 – actor và Quản lý đề nghị thưởng/phạt.
- **Khác với code:** Tài liệu ghi actor của chấm công và mô tả cộng phép theo tháng/thâm niên/vị trí trong chức năng đề nghị thưởng/phạt; service thực tế xử lý đề nghị, dòng nhân viên, số tiền và phê duyệt.
- **Cách sửa:** Đổi tên actor về thưởng/phạt; thay đoạn về phép bằng “Tạo đề nghị, chọn loại điều chỉnh/hình thức chi trả, thêm nhân viên và số tiền, lưu nháp, gửi duyệt”.
- **Căn cứ:** [AdjRequestService.cs:367](D:/Works/HRM/Web.Api/Services/AdjRequestService.cs:367).

**13.2. Trạng thái Cancelled của đề nghị không được triển khai**

- **Vị trí:** III – bảng trạng thái; IV/ERD AdjRequests; V AdjRequestStatus.
- **Khác với code:** Code AdjRequestStatus chỉ có New/Pending/Approved/Rejected. RecallAdjRequest chuyển Pending về New, xóa liên kết và instance quy trình cũ. Không nhầm với AdjAdjustmentStatus.Cancelled vẫn có.
- **Cách sửa:** Bỏ Cancelled=4 khỏi trạng thái đề nghị; bổ sung thao tác thu hồi về nháp đúng điều kiện. Giữ Cancelled trong trạng thái khoản điều chỉnh nếu mô tả đúng AdjAdjustmentStatus.
- **Căn cứ:** [AdjRequestStatus.cs:1](D:/Works/HRM/Web.Models/Enums/AdjRequestStatus.cs:1); [AdjRequestService.cs:572](D:/Works/HRM/Web.Api/Services/AdjRequestService.cs:572).

### 14. Tính lương v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1EuSw-AAyAp6hWuedGRlf13kV8CMdjP8oZOnqqESmWaE/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/14.txt)

**14.1. Công thức giờ theo chấm công thiếu hai thành phần**

- **Vị trí:** II.2.2 – Actual Working Hours.
- **Khác với code:** Tài liệu ghi giờ chấm công + giờ nghỉ có lương. Code còn trừ giờ OT đã tách riêng và cộng giờ ngày lễ.
- **Cách sửa:** Thay bằng tổng RealWorkingHour + paidLeaveHours − overtimeHours + holidayHours. Giải thích OT được tính riêng ở OTPay để người kiểm thử không cộng hai lần theo công thức rút gọn.
- **Căn cứ:** [PayrollCalculationService.cs:869](D:/Works/HRM/Web.Api/Services/PayrollCalculationService.cs:869).

**14.2. Thiếu tính theo các giai đoạn lương/phụ cấp trong kỳ**

- **Vị trí:** II.2 – công thức tính trên một mức lương và phụ cấp chung.
- **Khác với code:** Code chia kỳ theo các mốc thay đổi lương và phụ cấp; phân bổ theo số ngày lịch của đoạn/kỳ, tính từng đoạn rồi cộng kết quả. Tài liệu chưa đủ để dự đoán trường hợp thay đổi giữa tháng.
- **Cách sửa:** Bổ sung bước chia kỳ tại ngày hiệu lực; tỷ lệ đoạn = số ngày lịch bao gồm hai đầu / số ngày lịch kỳ. Tính lương/phụ cấp/giờ từng đoạn theo CalculateGrossSegment, sau đó tổng hợp; thêm ví dụ nhân viên đổi mức lương giữa kỳ.
- **Căn cứ:** [PayrollCalculationService.cs:427](D:/Works/HRM/Web.Api/Services/PayrollCalculationService.cs:427); [PayrollCalculationService.cs:685](D:/Works/HRM/Web.Api/Services/PayrollCalculationService.cs:685); [PayrollCalculationService.cs:831](D:/Works/HRM/Web.Api/Services/PayrollCalculationService.cs:831).

### 15. Đánh giá nhân viên v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/13RDs6DI9zef-9okzpUz_bJliYdQ26d_5xhlnL7a0d9o/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/15.txt)

**15.1. Enum đánh giá thiếu Đã gửi và sai mã Đã hủy**

- **Vị trí:** V – EvaluationStatus.
- **Khác với code:** Tài liệu chỉ có Draft=1, Cancelled=2. Code có Draft=1, Submitted=2, Cancelled=3; quyền sửa/xóa và gửi phụ thuộc trạng thái này.
- **Cách sửa:** Thay enum; bổ sung luồng lưu nháp/gửi chính thức và khóa sửa sau Submitted. Đồng bộ bộ lọc, sơ đồ trạng thái và testcase; không đọc giá trị 2 thành Đã hủy.
- **Căn cứ:** [EvaluationStatus.cs:5](D:/Works/HRM/Web.Models/Enums/EvaluationStatus.cs:5); [EmployeeEvaluationService.cs:826](D:/Works/HRM/Web.Api/Services/EmployeeEvaluationService.cs:826).

**15.2. Sai tên khóa liên kết trong ERD**

- **Vị trí:** IV – EvaluationCriterionLevels, EmployeeEvaluationDetails.
- **Khác với code:** Tài liệu dùng EvaluationCriterionLevels.CriteriaId, nhưng entity dùng CriterionId; chi tiết đánh giá dùng EvaluationId, không phải EmployeeEvaluationId.
- **Cách sửa:** Đổi tên cột và các Ref ở ERD; đối chiếu lại bảng mô tả cùng hai entity để tránh sinh schema hoặc truy vấn sai.
- **Căn cứ:** [EvaluationCriterionLevel.cs:13](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EvaluationCriterionLevel.cs:13); [EmployeeEvaluationDetail.cs:12](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/EmployeeEvaluationDetail.cs:12).

### 16. Quản lý mục tiêu OKR v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1EzkomlMc-IwaUtu0cQ7ZpU40rfalrgurbMA_Rugionk/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/16.txt)

**16.1. Luồng phê duyệt OKR không có trong phiên bản code đang xét**

- **Vị trí:** I; II.4 – phê duyệt mục tiêu; II.6.8 – duyệt điều chỉnh; UI; enum và ERD liên quan.
- **Khác với code:** Code áp dụng mục tiêu trực tiếp bằng ApplyObjectiveAsync. Objective chỉ có Draft/Active/Completed/Cancelled; ChangeRequest chỉ Draft/Applied/Cancelled. Các trường workflow/submitted/rejected mô tả trong tài liệu không có trên entity tương ứng; seed còn loại bỏ cấu hình OKR cũ.
- **Cách sửa:** Sửa xuyên suốt tài liệu theo luồng trực tiếp: Nháp → Áp dụng → Active; đề nghị điều chỉnh Nháp → Áp dụng → Applied. Bỏ các nút Gửi duyệt/Rút duyệt/Từ chối và các trạng thái, cột workflow không có. Nếu muốn giữ phê duyệt như định hướng tương lai, đặt vào mục yêu cầu chưa triển khai, không mô tả là tính năng hiện có.
- **Căn cứ:** [OKRService.cs:885](D:/Works/HRM/Web.Api/Services/OKRService.cs:885); [OKREnums.cs:19](D:/Works/HRM/Web.Models/Enums/OKREnums.cs:19); [OKRObjectiveChangeRequest.cs:1](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/OKRObjectiveChangeRequest.cs:1); [WebDbContextSeed.cs:83](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Data/WebDbContextSeed.cs:83).

### 17. Chat nội bộ v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1jXPsizn4rWFe1aJfI3-Z_S_krtj2mVNj/edit?usp=drivesdk&rtpof=true&sd=true) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/17.txt)

**17.1. Sai giới hạn thời gian chỉnh sửa tin nhắn**

- **Vị trí:** II.6.1 – câu “Hiện tại không có giới hạn thời gian edit…”.
- **Khác với code:** Code vẫn giới hạn 30 phút bằng hằng MessageEditWindowMinutes. Việc bỏ key cấu hình không đồng nghĩa bỏ giới hạn.
- **Cách sửa:** Thay bằng “Chỉ người gửi được sửa tin của mình trong vòng 30 phút kể từ lúc gửi, nếu tin chưa thu hồi và còn quyền gửi; giới hạn hiện được đặt cố định trong code.”
- **Căn cứ:** [ChatService.cs:1474](D:/Works/HRM/Web.Api/Services/ChatService.cs:1474); [Constant.cs:114](D:/Works/HRM/Web.Models/SeedWork/Constant.cs:114).

### 18. Đào tạo nội bộ LMS v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1clTX6uY9X_C_SMdSDkNdtLh6CGvh9hU_8bRkG6Mmt9k/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/18.txt)

**18.1. Nội dung học không tự đổi theo bài gốc sau khi phát hành**

- **Vị trí:** I.4.2; II – quản lý bài học; UI học bài, câu “xem nội dung mới nhất”.
- **Khác với code:** Code chụp tiêu đề, nội dung, video, file và ngân hàng câu hỏi vào quan hệ phiên bản khóa học khi phát hành. Phiên bản đã phát hành đọc snapshot; phiên bản nháp mới đọc bài gốc.
- **Cách sửa:** Thay các câu cập nhật bài gốc tự ảnh hưởng học viên bằng “Học viên xem nội dung đã chốt theo phiên bản khóa học; để áp dụng nội dung mới cần chuẩn bị/phát hành phiên bản phù hợp”. Giải thích riêng snapshot nội dung khi phát hành và snapshot đề khi bắt đầu làm bài.
- **Căn cứ:** [LmsCourseService.cs:1084](D:/Works/HRM/Web.Api/Services/LmsCourseService.cs:1084); [LmsCourseService.cs:1191](D:/Works/HRM/Web.Api/Services/LmsCourseService.cs:1191); [LmsCourseVersionLesson.cs:21](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/LmsCourseVersionLesson.cs:21).

**18.2. Thiết kế dữ liệu LMS dùng tên trường/bảng cũ**

- **Vị trí:** IV/ERD – LmsCourseVersions, LmsCourseLessons và các bảng kiểm tra.
- **Khác với code:** Ví dụ: VersionNo → VersionNumber; LessonAccessType → LessonAccessMode; FinalTestPassPercent → FinalTestPassPercentage. Quan hệ khóa học–bài học trong code là LmsCourseVersionLesson, có thêm các trường snapshot và QuestionBankVersionId.
- **Cách sửa:** Đồng bộ bảng mô tả và ERD theo entity hiện hành. Đổi các tên trên; TestPassPercent → TestPassPercentage; nhóm cờ bài học dùng TestShowScore/TestShowQuestionResult/TestShowCorrectAnswer; cuối khóa dùng FinalTestShowScore/FinalTestShowQuestionResult/FinalTestShowCorrectAnswer. Thêm snapshot thay vì chỉ sửa tên.
- **Căn cứ:** [LmsCourseVersion.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/LmsCourseVersion.cs:7); [LmsCourseVersionLesson.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/LmsCourseVersionLesson.cs:7).

**18.3. Trạng thái chứng nhận thiếu chờ duyệt**

- **Vị trí:** V – LmsCertificateStatus; IV – LmsCertificates.
- **Khác với code:** Enum tài liệu chỉ Active=1, Revoked=2; code có PendingApproval=3 và khởi tạo chứng nhận ở trạng thái này, hoàn tất workflow mới Active. Các cột WorkflowId/SubmittedAt/ApprovedAt trong ERD không nằm trên LmsCertificate hiện tại.
- **Cách sửa:** Bổ sung PendingApproval=3; mô tả trạng thái xử lý duyệt qua WorkflowInstance. Chứng nhận lưu WorkflowInstanceId, cấu hình workflow cấp chứng nhận nằm trên CourseVersion.CertificateWorkflowId; sửa ERD theo các entity này.
- **Căn cứ:** [LmsEnums.cs:1](D:/Works/HRM/Web.Models/Enums/LmsEnums.cs:1); [LmsCertificate.cs:63](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/LmsCertificate.cs:63); [LmsCertificateService.cs:164](D:/Works/HRM/Web.Api/Services/LmsCertificateService.cs:164).

### 19. Quản lý thiết bị v1.0

[Tài liệu Google Drive](https://docs.google.com/document/d/1g0IxgqYBSpqGAudJwRH6iRjpNjfXKeUlHWCNfUr-_aY/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/19.txt)

**19.1. Mô tả loại thiết bị cố định và khấu hao trái với module đang có**

- **Vị trí:** I.4.2 và các đoạn danh mục tài sản/khấu hao.
- **Khác với code:** Tài liệu nói danh mục cố định được seed, người dùng không thêm/sửa/xóa và hệ thống kiểm tra thời gian khấu hao. Code có DeviceType theo CompanyId cùng API/service tạo, sửa, xóa; entity Asset hiện không có các trường thời gian khấu hao/giá mua nêu trong tài liệu.
- **Cách sửa:** Viết lại thành danh mục loại thiết bị do doanh nghiệp quản lý theo quyền Asset/Asset.Catalog; chỉ xóa khi chưa dùng. Bỏ khẳng định module đã có phân loại cố định và kiểm tra khấu hao. Nếu đó là yêu cầu mới, tách rõ chưa triển khai. Đây là đối chiếu chức năng code, không phải đánh giá quy định pháp luật.
- **Căn cứ:** [AssetsController.cs:55](D:/Works/HRM/Web.Api/Api/Controllers/AssetsController.cs:55); [AssetService.cs:54](D:/Works/HRM/Web.Api/Services/AssetService.cs:54); [AssetEntities.cs:50](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AssetEntities.cs:50).

**19.2. ERD tài sản khác entity trên nhiều bảng**

- **Vị trí:** IV – Assets, AssetSuppliers, AssetHandovers, AssetDocuments.
- **Khác với code:** Ví dụ tài liệu dùng AssetTypeId, PurchasePrice, HandoverType, SenderEmployeeId/ReceiverEmployeeId; code dùng DeviceTypeId, Type và mô hình From/To có cả người đại diện. Asset không có PurchasePrice.
- **Cách sửa:** Sửa Assets.AssetTypeId → DeviceTypeId và liên kết DeviceTypes; bỏ PurchasePrice khỏi schema hiện hành. Supplier: ContactName → ContactPerson, Description → Note. Handover: HandoverType → Type, ExpectedHandoverDate → HandoverDate; vẽ đúng FromEmployeeId/ToEmployeeId và From/ToRepresentativeEmployeeId, không gom các vai trò thành một người gửi/nhận. AssetDocuments dùng Type, Note, ReferenceType, ReferenceId; thay các FK rời HandoverId/ReportId/MaintenanceId/DisposalId trong ERD bằng cơ chế tham chiếu này.
- **Căn cứ:** [AssetEntities.cs:7](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AssetEntities.cs:7); [AssetEntities.cs:80](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AssetEntities.cs:80); [AssetEntities.cs:158](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/AssetEntities.cs:158).

### 20. Bản tin nội bộ v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1nfVhg82vlA-jY7J7E9YIkFyCnjR-24pHcSPJb30d9k4/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/20.txt)

**20.1. Bản tin đã hỗ trợ nháp và có đủ năm trạng thái**

- **Vị trí:** I.6.3; II/III – tạo, sửa, xóa nháp, gửi duyệt; enum, bộ lọc và ERD trạng thái.
- **Khác với code:** `NewsPostStatus` gồm Draft=0, Pending=1, Approved=2, Recalled=3, Rejected=4. UI danh sách dùng “Chờ duyệt”, trong khi chi tiết hiển thị Pending là “Chưa duyệt”. Khi workflow từ chối, bản tin chuyển thành Rejected; gửi lại mới chuyển sang Pending.
- **Cách sửa:** Tài liệu đã tách Lưu nháp và Tạo/gửi duyệt; bổ sung đủ năm giá trị ở phần trạng thái, bộ lọc, ví dụ và schema. Ghi rõ nhãn Pending khác nhau giữa danh sách và chi tiết. Bản nháp vẫn qua kiểm tra dữ liệu và workflow tại `CreateDraftAsync`.
- **Căn cứ:** [NewsService.cs:769](D:/Works/HRM/Web.Api/Services/NewsService.cs:769); [NewsService.cs:858](D:/Works/HRM/Web.Api/Services/NewsService.cs:858); [NewsService.cs:1964](D:/Works/HRM/Web.Api/Services/NewsService.cs:1964); [NewsEnums.cs:10](D:/Works/HRM/Web.Models/Enums/NewsEnums.cs:10); [NewsManagement.razor:663](D:/Works/HRM/Web.App/Pages/News/NewsManagement.razor:663).

### 21. Quản lý công việc v1.1

[Tài liệu Google Drive](https://docs.google.com/document/d/1hDfiC4mPzx3_LJNLd2TgQ_2xCRXEx0Z1uOqPo46DSTk/edit?usp=drivesdk) · [Bản text dùng đối chiếu](D:/Works/HRM/tmp/doc-code-review/21.txt)

**21.1. Phạm vi xem và quyền trong tài liệu không đúng code**

- **Vị trí:** II.3.2, II.3.4, II.6.2, II.17 và danh sách quyền.
- **Khác với code:** Không có mã `Work.View`. Danh sách chung yêu cầu `Work.Assign` và lọc theo Department scope của Người thực hiện hiện tại hoặc Người yêu cầu nếu chưa có người thực hiện. `/api/WorkItems/my` lấy công việc Mới hoặc được giao cho nhân viên hiện tại. Chi tiết chỉ lọc theo CompanyId/Id; hiện không có kiểm tra `Work.View` hoặc quan hệ vai trò. Hàng đợi duyệt dùng `Work.Approve`.
- **Cách sửa:** Tài liệu đã thay quyền giả định bằng đúng scope endpoint, tách `Work.Assign` và `Work.Approve`, đồng thời ghi rõ giới hạn truy cập chi tiết đang được code thực thi.
- **Căn cứ:** [Constant.cs:359](D:/Works/HRM/Web.Models/SeedWork/Constant.cs:359); [WorkItemService.cs:64](D:/Works/HRM/Web.Api/Services/WorkItemService.cs:64); [WorkItemService.cs:274](D:/Works/HRM/Web.Api/Services/WorkItemService.cs:274); [WorkItemsController.cs:35](D:/Works/HRM/Web.Api/Api/Controllers/Work/WorkItemsController.cs:35).

**21.2. Thiết kế xóa mềm và giữ lịch sử không khớp code**

- **Vị trí:** II.8, II.10; IV/ERD – WorkTypes, WorkLabels, WorkItems, WorkAttachments, WorkComments và WorkCommentAttachments.
- **Khác với code:** Entity không có `IsDeleted`, `DeletedAt`, `DeletedByEmployeeId`. `DeleteAsync` xóa vật lý WorkItem cùng assignments, attachments, comments, comment attachments, labels và WorkHistories; loại công việc/nhãn cũng bị xóa vật lý khi chưa được sử dụng.
- **Cách sửa:** Tài liệu đã bỏ cột xóa mềm khỏi các bảng/ERD, sửa mô tả xóa và loại bỏ lời hứa giữ lịch sử kỹ thuật sau khi xóa. Phân biệt xóa vật lý với trạng thái Hủy.
- **Căn cứ:** [WorkItemService.cs:590](D:/Works/HRM/Web.Api/Services/WorkItemService.cs:590); [WorkItem.cs:6](D:/Works/HRM/Web.Api/Infrastructure/Persistence/Entities/WorkItem.cs:6); [WorkTypeService.cs:106](D:/Works/HRM/Web.Api/Services/WorkTypeService.cs:106); [WorkLabelService.cs:92](D:/Works/HRM/Web.Api/Services/WorkLabelService.cs:92).

**21.3. Bình luận không có thao tác sửa/xóa riêng**

- **Khác với code:** Controller chỉ có API thêm bình luận; API kiểm tra công việc còn mở nhưng không kiểm tra vai trò người bình luận. Bình luận và file liên quan bị xóa vật lý cùng công việc.
- **Cách sửa:** Tài liệu đã bỏ luồng sửa/xóa bình luận và soft-delete; mô tả đúng điều kiện API hiện có.
- **Căn cứ:** [WorkItemsController.cs:177](D:/Works/HRM/Web.Api/Api/Controllers/Work/WorkItemsController.cs:177); [WorkItemService.cs:1227](D:/Works/HRM/Web.Api/Services/WorkItemService.cs:1227); [WorkItemService.cs:631](D:/Works/HRM/Web.Api/Services/WorkItemService.cs:631).

## Kết quả cập nhật trên Google Drive

- Đã cập nhật trực tiếp tài liệu 01–21 và tăng version từng file một bậc. Tài liệu `00. Tổng quan hệ thống HRM v1.0` được giữ nguyên theo yêu cầu.
- Trước khi sửa, mỗi bản cũ được sao chép vào `HRM - Lịch sử thay đổi`; danh sách Drive xác nhận đủ 21 bản sao.
- Hai tài liệu vừa hoàn tất: [20. Bản tin nội bộ v1.1](https://docs.google.com/document/d/1nfVhg82vlA-jY7J7E9YIkFyCnjR-24pHcSPJb30d9k4/edit) và [21. Quản lý công việc v1.1](https://docs.google.com/document/d/1hDfiC4mPzx3_LJNLd2TgQ_2xCRXEx0Z1uOqPo46DSTk/edit). Bản trước sửa: [20. v1.0](https://docs.google.com/document/d/1EOrRllDk1sQShp-y9s9v60roRi76qW1AiKzEVNXly4E/edit), [21. v1.0](https://docs.google.com/document/d/1KMZHhjDAihlBtYRHeGzFwE5ruM3CXbL8X8l1yOHSV-s/edit).
- Kiểm tra sau sửa cho tài liệu 20/21 xác nhận tiêu đề và số bảng được giữ nguyên; các hàng schema và dòng ERD sai đã được loại bỏ. Với tài liệu 17 dạng DOCX, đã kiểm tra cấu trúc; không có môi trường render hoạt động để xác minh bằng ảnh trang.

## Cách cập nhật để không sót các phần liên quan

1. Sửa các luồng nghiệp vụ trước: điều kiện đầu vào, thao tác, trạng thái trước/sau và điều kiện thất bại. Với chức năng chưa có, bỏ khỏi mô tả hiện trạng hoặc chuyển sang yêu cầu dự kiến.
2. Với mỗi điểm đã sửa, tìm toàn bộ tên cũ/câu cũ trong cùng file để cập nhật phần mô tả, nghiệp vụ, wireframe, bảng dữ liệu, ERD và phụ lục. Không chỉ sửa enum ở cuối tài liệu.
3. Với tên trường/enum/quyền, lấy đúng định nghĩa hiện tại từ entity, enum, Constant và cấu hình EF; không tự đổi giá trị số cho liên tục. Một số enum cố ý để khoảng trống sau khi bỏ trạng thái.
4. Đồng bộ chéo: 01 ↔ 21 về quyền công việc; 02 ↔ 07 ↔ các module sử dụng workflow; 03 ↔ 06 ↔ 14 về bảo hiểm; 05 ↔ 10 ↔ 11 ↔ 14 về ca/giờ công; 07 ↔ 18/19/20/21 về loại quy trình.
5. Thêm ngày đối chiếu và commit source vào lịch sử phiên bản tài liệu. Giữ các bản cũ trong thư mục lịch sử; không sửa chúng thành bản hiện hành.

Các nội dung không được liệt kê ở trên chưa được chứng nhận là đúng toàn bộ. Báo cáo ưu tiên các điểm có căn cứ trực tiếp trong source; việc kiểm tra trình bày, ảnh chụp màn hình và toàn bộ tình huống chạy thực tế nằm ngoài lần đối chiếu tĩnh này.


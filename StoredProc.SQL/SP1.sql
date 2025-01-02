use ITI_ExamSystem
--Exam - stu exam - stu exam questions -  Question - q choices
---------------------------------------
--Exam--
--insert into exam
create proc SP_generateExam
	@exName varchar(50) , @numOfTF int , @numOFMCQ int ,
	@exDate date , @exDuration int , @courseId int , @exId int output
AS	
begin
	BEGIN TRY
	insert into Exam (ex_date , duration , name , crs_id)
	values (@exDate , @exDuration , @exName , @courseId)
	set @exId = SCOPE_IDENTITY()
	
	insert into Exam_questions ( ex_id , q_id)
	select @exId , id
	from
	(
		select top (@numOfTF) id from Question where crs_id = @courseId
		and type = 'TF' order by NEWID()
		UNION ALL
		select top (@numOFMCQ) id from Question where crs_id = @courseId
		and type = 'MCQ' order by NEWID()
	) as RandomQuestions
        PRINT 'Questions inserted into Exam_questions table: ' + CAST(@numOfTF + @numOFMCQ AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
		ROLLBACK TRANSACTION;
    END CATCH
END;
--
DECLARE @outputExId INT
EXEC SP_generateExam 
     'Temp1', 
      10, 
      0, 
      '2024-12-12', 
      120, 
      1, 
      @outputExId OUTPUT;
SELECT @outputExId AS GeneratedExamID;
---------------------------------------
--insert exam Question

create proc SP_insertExamQuestions
@examId int ,
@questionId int
as
begin
	insert into Exam_questions(ex_id , q_id)
	values (@examId , @questionId)
end
--
exec SP_insertExamQuestions 6 , 150
---------------------------------------
--update exam
alter Procedure SP_updateExam
	@examId INT, @examName NVARCHAR(50) = NULL ,
	@examDate DATE = NULL, @examDuration INT = NULL, @crsId INT = NULL
as
begin
		IF EXISTS (SELECT 1 FROM Exam WHERE id = @examId)
		begin
			update Exam set 
			name = ISNULL(@examName, Exam.name),           
            ex_date = ISNULL(@examDate, ex_date),         
            duration = ISNULL(@examDuration, duration),   
            crs_id = ISNULL(@crsId, crs_id) 
			where Exam.id = @examId
		end
		else
		begin
			select 'Exam does not exist'
		end
end
--
exec SP_updateExam
@examId = 6,
@examName ='C sharp fundmentals' 

---------------------------------------
--update Exam Questions
create proc SP_updateExamQuestions
@examid int , @questionId int , @newQuestionId int
as
begin
	IF EXISTS (SELECT 1 FROM Exam_questions WHERE ex_id = @examId and q_id = @questionid )
	begin
		update Exam_questions 
		set q_id = @newQuestionId
		 WHERE ex_id = @examId and q_id = @questionid
	end
	else
	begin
		select 'Enter real data'
	end
end
--
exec SP_updateExamQuestions
@examid = 7 ,
@questionId = 1 ,
@newQuestionId = 2
---------------------------------------
--delete exam
create proc SP_deleteExam
@examID int
as
begin
	IF EXISTS (SELECT 1 FROM Exam WHERE id = @examId)
	begin
		delete from Exam_questions where ex_id = @examID
		delete from Exam where id = @examID
	end
	else
	begin
		select 'This exam does not exist'
	end
end
--
exec SP_deleteExam
@examID =11
---------------------------------------
--delete Exam Questions
create proc SP_deleteExamQuestions
@examID int ,
@QuestionId int
as
begin
	IF EXISTS (SELECT 1 FROM Exam_questions WHERE ex_id = @examID and q_id = @questionid)
	begin
		delete from Exam_questions where ex_id = @examID and q_id = @QuestionId
	end
	else
	begin
		select 'This question or this exam does not exist'
	end
end
--
exec SP_deleteExamQuestions
@examID = 6 ,
@QuestionId = 150
---------------------------------------	
--select Exam
CREATE PROC SP_selectExam
    @ex_id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Exam WHERE id = @ex_id)
        BEGIN
            SELECT * FROM Exam WHERE id = @ex_id;
        END
        ELSE
        BEGIN
            PRINT 'This Exam Does not Exist';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting the exam.';
    END CATCH
END
--
exec SP_selectExam @ex_id = 6
---------------------------------------
--select exam questions

CREATE PROC SP_selectExamQuestion
    @ex_id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Exam_questions WHERE ex_id = @ex_id)
        BEGIN
            SELECT 
                eq.q_id, q.q_head, q.model_ans
            FROM 
                Exam_questions eq INNER JOIN Question q
            ON eq.q_id = q.id
            WHERE eq.ex_id = @ex_id;
        END
        ELSE
        BEGIN
            PRINT 'No questions found for the given exam ID.';
        END
    END TRY
    BEGIN CATCH
        -- Handle any errors that occur
        PRINT 'An error occurred while selecting the exam questions.';
    END CATCH
END;
--
exec SP_selectExamQuestion @ex_id = 6


---------------------------------------
--insert Questions

create proc SP_insertQuestions
@questionHead varchar(400),
@modelAnswer varchar(200),
@grade int = NULL,
@type varchar(10),
@courseId int,
@choiceOne varchar(200) = NULL,
@choiceTwo varchar(200) = NULL,
@choiceThree varchar(200) = NULL,
@choiceFour varchar(200) = NULL,
@questionId int output
as
begin
	IF Exists (select 1 from Course where id = @courseId)
	begin
		insert into Question (q_head , model_ans , grade , type ,crs_id)
		values (@questionHead , @modelAnswer ,ISNULL(@grade , 10) , @type , @courseId)
		set @questionId = SCOPE_IDENTITY()
		if @type = 'TF'
		begin
			insert into Question_choices (q_id , choice)
			values (@questionId , 'True') ,(@questionId , 'False')
		end
		else
			begin
			IF @choiceOne IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceOne);
            IF @choiceTwo IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceTwo);
            IF @choiceThree IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceThree);
            IF @choiceFour IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceFour);
		end
	end
	else
	begin
		select 'this course does not exit'
	end
end
--
DECLARE @questionId INT

exec SP_insertQuestions
'What is the default value of a boolean variable in C#?',
@modelAnswer = 'False',
@type = 'MCQ',
@courseId = 2,
@choiceOne = 'True',
@choiceTwo = 'False',
@choiceThree = 'null',
@choiceFour = '0',
@questionId = @questionId OUTPUT
SELECT @questionId AS GeneratedQuestionID;
---------------------------------------
--update question
alter proc SP_updateQuestions
@questionId int,
@modelAnswer varchar(200) = NULL,
@grade int = NULL,
@type varchar(10)= NULL,
@courseId int = NULL,
@choiceOne varchar(200) = NULL,
@choiceTwo varchar(200) = NULL,
@choiceThree varchar(200) = NULL,
@choiceFour varchar(200) = NULL
as
begin
	BEGIN TRANSACTION;
	begin try
	IF Exists (select 1 from Question where id = @questionId)
	begin
		update Question
		set model_ans = ISNULL(@modelAnswer , model_ans) ,
			grade = ISNULL(@grade , grade),
			type = ISNULL(@type , type) ,
			crs_id = ISNULL(@courseId , crs_id) 
		where id = @questionId
		--update choices
		if @type = 'TF'
		begin
			delete from Question_choices where q_id = @questionId 
			insert into Question_choices (q_id , choice)
			values (@questionId , 'True') ,(@questionId , 'False')
		end
		else
		begin
			DELETE FROM Question_choices WHERE q_id = @questionId
			IF @choiceOne IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceOne)
            IF @choiceTwo IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceTwo)
            IF @choiceThree IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceThree)
            IF @choiceFour IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceFour)
		end
	end
	else
	begin
		SELECT 'Question does not exist' AS ErrorMessage;
		ROLLBACK TRANSACTION;
	end
	COMMIT TRANSACTION;
end try
BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    END CATCH
end

--
EXEC SP_updateQuestions
    @questionId = 173,
    @type = 'MCQ',
	@modelAnswer = 'False',
    @courseId = 2,
    @choiceOne = '0',
    @choiceTwo = 'False',
    @choiceThree = 'NULL',
    @choiceFour = 'True';
---------------------------------------
--update Question Choices
create proc SP_updateQuestionChoices
    @questionId INT,
    @choiceOne varchar(200) = NULL,
    @choiceTwo varchar(200) = NULL,
    @choiceThree varchar(200) = NULL,
    @choiceFour varchar(200) = NULL
as
BEGIN
    begin TRANSACTION;
    begin TRY
        -- Check if the question exists
        IF EXISTS (SELECT 1 FROM Question WHERE id = @questionId)
        begin
            -- Delete existing choices for the question
            DELETE FROM Question_choices WHERE q_id = @questionId;

            -- Insert new choices if provided
            IF @choiceOne IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceOne);
            IF @choiceTwo IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceTwo);
            IF @choiceThree IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceThree);
            IF @choiceFour IS NOT NULL
                INSERT INTO Question_choices (q_id, choice) VALUES (@questionId, @choiceFour);
        end
        ELSE
        BEGIN
            SELECT 'Question does not exist'
            ROLLBACK TRANSACTION;
            RETURN;
        end

        COMMIT TRANSACTION;
    end TRY
    begin CATCH
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred: ' + ERROR_MESSAGE();
    end CATCH
end;

exec SP_updateQuestionChoices
@questionId = 3,
@choiceOne = 'href',
@choiceTwo='image-source',
@choiceThree='src',
@choiceFour='url'


---------------------------------------
--delete question
create proc SP_deleteQuestion
@questionID int
as
begin
	IF Exists (select 1 from Question where id = @questionId)
	begin
		delete from Exam_questions where q_id = @questionID
		delete from Question_choices where Question_choices.q_id = @questionId
		delete from Question where id = @questionID
	end
	else
	begin
		select 'This Question does not in the system'
	end
end
--
exec SP_deleteQuestion
@questionID = 95
------------------------------------
--delete choices

alter proc SP_deleteQuestionChoices
@questionID int
as
begin

	delete from Question_choices where Question_choices.q_id = @questionId
		delete from Question where id = @questionID
end
---------------------------------------
use ITI_ExamSystem
--select questions
alter PROC SP_selectQuestions
    @q_id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Question WHERE id = @q_id)
        BEGIN
            SELECT * 
            FROM Question 
            WHERE id = @q_id;

			 SELECT * 
            FROM Question_choices 
            WHERE q_id = @q_id;
        END
        ELSE
        BEGIN
            PRINT 'This question does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while retrieving the question.';
    END CATCH
END
--
exec SP_selectQuestions @q_id = 72
---------------------------------------
--select question choices
create PROC SP_selectQuestionChoices
    @q_id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Question WHERE id = @q_id)
        BEGIN
			 SELECT * 
            FROM Question_choices 
            WHERE q_id = @q_id;
        END
        ELSE
        BEGIN
            PRINT 'This question does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while retrieving the question.';
    END CATCH
END
--
exec SP_selectQuestionChoices @q_id = 73
---------------------------------------
--insert student exam questions
CREATE TYPE AnswerTableType AS TABLE
(
    q_id INT,
    stu_ans VARCHAR(200)
)

alter proc SP_insertStudentExamQuestionAns
@stu_id int , @ex_id int , @answers dbo.AnswerTableType READONLY
as
begin
	begin transaction
	begin try
	IF NOT EXISTS (SELECT 1 FROM Student s WHERE s.id = @stu_id)
        BEGIN
            THROW 50002, 'The specified student does not exist in the Student table.', 1;
        END
	IF NOT EXISTS (SELECT 1 FROM dbo.Exam WHERE id = @ex_id)
        BEGIN
            THROW 50003, 'The specified exam does not exist in the Exam table.', 1;
        END
	IF EXISTS (
            SELECT 1
            FROM @answers a
            LEFT JOIN Exam_questions eq
                ON eq.ex_id = @ex_id AND eq.q_id = a.q_id
            WHERE eq.q_id IS NULL
        )
		BEGIN
            THROW 50001, 'One or more questions do not belong to the specified exam.', 1;
        END
		INSERT INTO Student_exam_questions (stu_id, ex_id, q_id, stu_ans)
        SELECT @stu_id, @ex_id, a.q_id, a.stu_ans
        FROM @answers a;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
--
select eq.q_id , q.q_head , q.model_ans
from Exam_questions eq inner join Question q
on eq.q_id = q.id
where eq.ex_id = 13
use ITI_ExamSystem
DECLARE @answers AnswerTableType;

INSERT INTO @answers (q_id, stu_ans)
VALUES 
    (21, 'True'),
    (22, 'False'),
    (24, 'True'),
    (29, 'False'),
    (30, 'True'),
    (31, 'False'),
    (33, 'True'),
    (34, 'False'),
    (38, 'False'),
    (39, 'False');

EXEC [dbo].[SP_insertStudentExamQuestionAns]
    @stu_id = 11, 
    @ex_id = 13, 
    @answers = @answers;
---------------------------------------
--update  student exam questions
create proc SP_updateStudentExamQuestions 
@stu_id int , @ex_id int , @q_id int , @new_ans varchar(200)
as
begin
	begin transaction
	begin try
		IF NOT EXISTS (
				select 1
				from Student_exam_questions
				where ex_id = @ex_id and stu_id = @stu_id
			)
		begin
			select 'No records found in this table according to your data'
		end
		update Student_exam_questions
		set stu_ans = @new_ans
		where stu_id = @stu_id and ex_id = @ex_id and q_id=@q_id

		commit transaction
	end try
	begin catch
		ROLLBACK TRANSACTION;
		THROW;
	end catch
end
--
exec SP_updateStudentExamQuestions
@stu_id = 11,
@ex_id = 13,
@q_id = 21,
@new_ans ='False'
	
---------------------------------------
--delete student exam questions

create proc SP_deleteStudentExamQuestions
@stu_id int , @ex_id int
as
begin
	begin transaction
	begin try
		IF NOT EXISTS (
			select 1
			from Student_exam_questions
			where ex_id = @ex_id and stu_id = @stu_id
		)
		begin
			select 'No records found in this table according to your data'
		end
		
		delete from Student_exam_questions
		where stu_id = @stu_id and ex_id = @ex_id
		
		commit transaction
		end try
		begin catch
			ROLLBACK TRANSACTION;
			THROW;
		end catch
end
--
exec SP_deleteStudentExamQuestions 
    @stu_id = 11  ,
    @ex_id = 13
--------------------------------
--select Student_exam_question

CREATE PROC SP_selectStudentExamQuestions
    @stu_id INT, 
    @ex_id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Student_exam_questions WHERE stu_id = @stu_id AND ex_id = @ex_id)
        BEGIN
            SELECT * 
            FROM Student_exam_questions 
            WHERE stu_id = @stu_id AND ex_id = @ex_id;
        END
        ELSE
        BEGIN
            PRINT 'This data does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while retrieving student exam questions.';
    END CATCH
END;
--
exec SP_selectStudentExamQuestions @ex_id = 13 , @stu_id = 11
---------------------------------

--exam correction for a student

alter proc SP_correctExam
    @stu_id int,
    @ex_id int,
    @examPercentage FLOAT OUTPUT
as
begin
    begin transaction;
    begin try
        if NOT EXISTS (select 1 from Student where id = @stu_id)
        begin
            select 'The specified student does not exist.'
        end

        if NOT EXISTS (select 1 from .Exam where id = @ex_id)
        begin
            select 'The specified exam does not exist.'
        end
		DECLARE @examGrade INT;
        select @examGrade = SUM(q.grade)
        FROM Student_exam_questions seq
        inner join Question q
            ON q.id = seq.q_id
        WHERE seq.stu_id = @stu_id 
          and seq.ex_id = @ex_id 
          and seq.stu_ans = q.model_ans;

		--insert into exam questions automaticly
		--insert into Student_exam (stu_id , ex_id , grade)
		--values (@stu_id ,@ex_id ,@examGrade)

        if @examGrade IS NULL
            set @examGrade = 0;

		DECLARE @maxGrade INT;
        SELECT @maxGrade = SUM(q.grade)
        FROM Question q inner join Exam_questions eq
		on q.id = eq.ex_id
        WHERE eq.ex_id = @ex_id;

		IF @maxGrade = 0
            SET @examPercentage = 0;
		ELSE
			SET @examPercentage = (@examGrade * 100.0) / @maxGrade;
        commit transaction;
    end try
    begin catch
        rollback transaction;
        throw;
    end catch
end;
--
DECLARE @precentage INT;

EXEC SP_correctExam 
    @stu_id = 11,  
    @ex_id = 13,   
    @examPercentage = @precentage OUTPUT;

PRINT @precentage; 

---------------------------------
--stu exam
--insert student exam
create proc SP_insertStudentExam
@stu_id int,
@ex_id int,
@grade int
as
begin
	begin transaction
	begin try
		if NOT EXISTS (select 1 from Student_exam_questions s where s.stu_id  = @stu_id)
        begin
            select 'The specified student does not exist.'
        end

        if NOT EXISTS (select 1 from Student_exam_questions s where s.ex_id = @ex_id)
        begin
            select 'The specified exam does not exist.'
        end
		insert into Student_exam (stu_id , ex_id , grade)
		values (@stu_id ,@ex_id ,@grade)

	commit transaction;
	end try
	begin catch
		rollback transaction;
        throw;
	end catch
end
--
exec SP_insertStudentExam
@stu_id = 11,
@ex_id = 13,
@grade = 70

---------------------
--update student exam

alter proc SP_updateStudentExam
@stu_id int,
@ex_id int,
@newGrade int
as
begin
	begin transaction
	begin try
		if NOT EXISTS (select 1 from Student_exam s where s.stu_id  = @stu_id)
        begin
            select 'The specified student does not exist.'
        end

        if NOT EXISTS (select 1 from Student_exam s where s.ex_id = @ex_id)
        begin
            select 'The specified exam does not exist.'
        end
		update Student_exam
		set grade = @newGrade
		where stu_id = @stu_id and ex_id = @ex_id

	commit transaction;
	end try
	begin catch
		rollback transaction;
        throw;
	end catch
end

--
exec SP_updateStudentExam
@stu_id =11,@ex_id=13,@newGrade=70

--------------------------------
--delete student exam

create proc SP_deleteStudentExam
@stu_id int,
@ex_id int
as
begin
	begin transaction
	begin try
		if NOT EXISTS (select 1 from Student_exam s where s.stu_id  = @stu_id)
        begin
            select 'The specified student does not exist.'
        end

        if NOT EXISTS (select 1 from Student_exam s where s.ex_id = @ex_id)
        begin
            select 'The specified exam does not exist.'
        end
		delete from Student_exam
		where stu_id = @stu_id and ex_id =@ex_id

	commit transaction;
	end try
	begin catch
		rollback transaction;
        throw;
	end catch
end

--

exec SP_deleteStudentExam
@stu_id = 11 ,@ex_id =13
------------------------------
--select student exam
CREATE PROC SP_selectStudentExam
    @stu_id INT = NULL,
    @ex_id INT = NULL   
AS
BEGIN
    BEGIN TRY
        IF @stu_id IS NOT NULL AND @ex_id IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM Student_exam WHERE stu_id = @stu_id AND ex_id = @ex_id)
            BEGIN
                SELECT * 
                FROM Student_exam 
                WHERE stu_id = @stu_id AND ex_id = @ex_id;
            END
            ELSE
            BEGIN
                PRINT 'This data does not exist.';
            END
        END
        ELSE IF @stu_id IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM Student_exam WHERE stu_id = @stu_id)
            BEGIN
                SELECT * 
                FROM Student_exam 
                WHERE stu_id = @stu_id;
            END
            ELSE
            BEGIN
                PRINT 'No records found for the specified student.';
            END
        END
        ELSE IF @ex_id IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM Student_exam WHERE ex_id = @ex_id)
            BEGIN
                SELECT * 
                FROM Student_exam 
                WHERE ex_id = @ex_id;
            END
            ELSE
            BEGIN
                PRINT 'No records found for the specified exam.';
            END
        END
        ELSE
        BEGIN
            PRINT 'Please provide at least one parameter: @stu_id or @ex_id.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while retrieving the student exam record.';
    END CATCH
END
--
exec SP_selectStudentExam @stu_id = 11 , @ex_id = 13

----------Fatma----------------
--branch
--insert branch
use ITI_ExamSystem
CREATE PROC Sp_InsertBranch
       @Name VARCHAR(50) = NULL  
AS
BEGIN
    BEGIN TRY
        INSERT INTO Branch (name)
        VALUES (ISNULL(@Name, NULL));  
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the branch.';
    END CATCH
END;
--
EXEC Sp_InsertBranch @Name = 'New Capital'

----------------------
--update branch
create PROC Sp_updateBranch
    @Id INT,
    @Name VARCHAR(50) = NULL  
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Branch WHERE id = @Id)
        BEGIN
            UPDATE Branch
            SET name = ISNULL(@Name, name)  
            WHERE id = @Id;

            -- Update related records in Branches_Tracks بس مفييش اصلا
            UPDATE Branches_tracks
            SET branch_id = @Id
            WHERE branch_id = @Id; -- No change in ID, but ensures related records are consistent  بيتاككد بس 
        END
        ELSE
        BEGIN
            PRINT 'Branch does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the branch.';
    END CATCH
END;

----------------------
--delete branch
CREATE PROC Sp_deleteBranch
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Branch WHERE id = @Id)
        BEGIN
		-- delete first in table based on branch 
			DELETE FROM Branches_tracks WHERE branch_id = @Id;
			--then delete from branch
		 DELETE FROM Branch WHERE id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Branch does not exist.';
        END 
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the branch.';
    END CATCH
END;

---------------------------
--select branch
CREATE PROC Sp_SelectBranch
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Branch WHERE id = @Id)
        BEGIN
            SELECT *
            FROM Branch
            WHERE id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Branch does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting the branch.';
    END CATCH
END;
GO

-----------------------------------
--Track
--insert track
CREATE PROC Sp_insertTrack
       @Name VARCHAR(50) = NULL,  -- default val
       @TrackMgr INT = NULL  
AS
BEGIN
    BEGIN TRY
        INSERT INTO Track (name, track_mgr)
        VALUES (ISNULL(@Name, NULL), ISNULL(@TrackMgr, NULL));  
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the Track.';
    END CATCH
END;

------------------------------
--update track
create PROC Sp_updateTrack
    @Id INT,
    @Name VARCHAR(50) = NULL,
    @TrackMgr INT = NULL  
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Track WHERE id = @Id)
        BEGIN
            UPDATE Track
            SET name = ISNULL(@Name, name), 
                track_mgr = ISNULL(@TrackMgr, track_mgr)  
            WHERE id = @Id;

            -- Update related records in Branches_Tracks >> مفيش قيم بس مجرد بناكد بس  انو مزال ال id ذي ماهووو
            UPDATE Branches_tracks
            SET track_id = @Id
            WHERE track_id = @Id;

            -- Update related records in Crs_Track
            UPDATE Crs_track
            SET track_id = @Id
            WHERE track_id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Track does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the track.';
    END CATCH
END;

-------------------------------
--delete track
CREATE PROC Sp_deleteTrack
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Track WHERE id = @Id)
        BEGIN
		    DELETE FROM Crs_track WHERE track_id = @Id;
		    DELETE FROM Branches_tracks WHERE track_id = @Id;
            DELETE FROM Track WHERE id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Track does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the Track.';
    END CATCH
END;

--------------------------
--select track
CREATE PROC Sp_selectTrack
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Track WHERE id = @Id)
        BEGIN
            SELECT id, name, track_mgr
            FROM Track
            WHERE id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Track does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting the Track.';
    END CATCH
END;

-----------------------------
--branch track
--insert branch track
CREATE PROC Sp_insertBranchesTracks
       @BranchId INT=NULL ,
       @TrackId INT =NULL  
AS
BEGIN
    BEGIN TRY
        -- If both branch_id and track_id are NULL
        IF @BranchId IS NULL OR @TrackId IS NULL
        BEGIN
            PRINT 'Both BranchId and TrackId are required.'; -- because of constraint of not null on these colums
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM Branches_tracks WHERE branch_id = @BranchId AND track_id = @TrackId)
        BEGIN
            INSERT INTO Branches_tracks (branch_id, track_id)
            VALUES (@BranchId, @TrackId);
        END
        ELSE
        BEGIN
            PRINT 'The record already exists in Branches_tracks.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the Branch-Track relationship.';
    END CATCH
END;

----------------------------
--update branch track
CREATE PROC Sp_updateBranchesTracks
    @OldBranchId INT,
    @OldTrackId INT,
    @NewBranchId INT = NULL,  
    @NewTrackId INT = NULL    
AS
BEGIN
    BEGIN TRY
        -- Ensure the old pair exists
        IF EXISTS (SELECT 1 FROM Branches_tracks WHERE branch_id = @OldBranchId AND track_id = @OldTrackId)
        BEGIN
            UPDATE Branches_tracks
            SET branch_id = ISNULL(@NewBranchId, branch_id),  
                track_id = ISNULL(@NewTrackId, track_id)
            WHERE branch_id = @OldBranchId AND track_id = @OldTrackId;
        END
        ELSE
        BEGIN
            PRINT 'The specified Branch-Track relationship does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the Branch-Track relationship.';
    END CATCH
END;

--------------------------------
--delete branch track
CREATE PROC Sp_deleteBranchesTracks
    @BranchId INT,
    @TrackId INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Branches_tracks WHERE branch_id = @BranchId AND track_id = @TrackId)
        BEGIN
            DELETE FROM Branches_tracks
            WHERE branch_id = @BranchId AND track_id = @TrackId;
        END
        ELSE
        BEGIN
            PRINT 'The specified Branch-Track relationship does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the Branch-Track relationship.';
    END CATCH
END;

-------------------------------
--select branch track
CREATE PROC Sp_SelectBranchesTracks
    @BranchId INT = NULL,
    @TrackId INT = NULL   
as
BEGIN
    BEGIN TRY
        -- If both BranchId and TrackId are provided
        IF @BranchId IS NOT NULL AND @TrackId IS NOT NULL
        BEGIN
            SELECT branch_id, track_id
            FROM Branches_tracks
            WHERE branch_id = @BranchId AND track_id = @TrackId;
        END
        -- If only BranchId is provided
        ELSE IF @BranchId IS NOT NULL
        BEGIN
            SELECT branch_id, track_id
            FROM Branches_tracks
            WHERE branch_id = @BranchId;
        END
        -- If only TrackId is provided
        ELSE IF @TrackId IS NOT NULL
        BEGIN
            SELECT branch_id, track_id
            FROM Branches_tracks
            WHERE track_id = @TrackId;
        END
        -- If no parameters are provided
        ELSE
        BEGIN
            PRINT 'Please provide either BranchId or TrackId to perform the selection.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting from Branches_tracks.';
    END CATCH
END;

----------------------------
--course
--insert course
CREATE PROC Sp_insertCourse
    @Name VARCHAR(50) = NULL  
AS
BEGIN
    BEGIN TRY
        INSERT INTO Course (name)
        VALUES (@Name);
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the course.';
    END CATCH
END;

-----------------------------
--update course
create PROC Sp_UpdateCourse
    @Id INT,
    @Name VARCHAR(50) = NULL  
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Course WHERE id = @Id)
        BEGIN
            UPDATE Course
            SET name = ISNULL(@Name, name)  
            WHERE id = @Id;

            -- Update related records in Topic
            UPDATE Topic
            SET crs_id = @Id
            WHERE crs_id = @Id;

            -- Update related records in Crs_Track
            UPDATE Crs_track
            SET crs_id = @Id
            WHERE crs_id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Course does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the course.';
    END CATCH
END;

------------------------------
--delete course
CREATE PROC Sp_deleteCourse
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Course WHERE id = @Id)
        BEGIN
		--added
		 update Question SET crs_id = NULL
		 DELETE FROM Student_crs where crs_id = @id	
		 --
		 DELETE FROM Crs_track WHERE crs_id = @Id;
         DELETE FROM Course WHERE id = @Id;
		 DELETE FROM Topic where crs_id = @Id
        END
        ELSE
        BEGIN
            PRINT 'Course does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the course.';
    END CATCH
END;

------------------------
--select course
CREATE PROC Sp_selectCourse
    @Id INT  
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Course WHERE id = @Id)
        BEGIN
            SELECT *
            FROM Course
            WHERE id = @Id;
        END
        ELSE
        BEGIN
            PRINT 'Course does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting the course.';
    END CATCH
END;

-------------------------------
-- Course Track
--insert crs_track
CREATE PROC Sp_InsertCrsTrack
    @TrackId INT = NULL,  
    @CrsId INT = NULL     
AS
BEGIN
    BEGIN TRY
        -- Check for NULL values
        IF @TrackId IS NULL OR @CrsId IS NULL
        BEGIN
            PRINT 'Both track_id and crs_id must be provided.';
        END
        ELSE
        BEGIN
            -- Check if the provided crs_id exists in the Course table
            IF NOT EXISTS (SELECT 1 FROM Course WHERE id = @CrsId)
            BEGIN
                PRINT 'The provided crs_id does not exist in the Course table.';
            END
            -- Check if the provided track_id exists in the Track table
            ELSE IF NOT EXISTS (SELECT 1 FROM Track WHERE id = @TrackId)
            BEGIN
                PRINT 'The provided track_id does not exist in the Track table.';
            END
            -- Check if the record already exists in Crs_track
            ELSE IF EXISTS (SELECT 1 FROM Crs_track WHERE track_id = @TrackId AND crs_id = @CrsId)
            BEGIN
                PRINT 'The record already exists in Crs_track.';
            END
            ELSE
            BEGIN
                -- Insert the record into Crs_track
                INSERT INTO Crs_track (track_id, crs_id)
                VALUES (@TrackId, @CrsId);
                PRINT 'Record inserted successfully into Crs_track.';
            END
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the record into Crs_track.';
    END CATCH
END;

----------------------
--update crs_track
CREATE PROC Sp_UpdateCrsTrack
    @TrackId INT = NULL, 
    @CrsId INT = NULL    
AS
BEGIN
    BEGIN TRY
       --return an error message
        IF @TrackId IS NULL OR @CrsId IS NULL
        BEGIN
            PRINT 'Both track_id and crs_id must be provided.';
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM Crs_track WHERE track_id = @TrackId AND crs_id = @CrsId)
            BEGIN
                UPDATE Crs_track
                SET track_id = @TrackId, crs_id = @CrsId
                WHERE track_id = @TrackId AND crs_id = @CrsId;
            END
            ELSE
            BEGIN
                PRINT 'The record does not exist in Crs_track.';
            END
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the record in Crs_track.';
    END CATCH
END;

---------------------------
--delete crs_track
CREATE PROC Sp_DeleteCrsTrack
    @TrackId INT,
    @CrsId INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Crs_track WHERE track_id = @TrackId AND crs_id = @CrsId)
        BEGIN
            DELETE FROM Crs_track
            WHERE track_id = @TrackId AND crs_id = @CrsId;
        END
        ELSE
        BEGIN
            PRINT 'The record does not exist in Crs_track.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the record from Crs_track.';
    END CATCH
END;

-----------------------------------------
--select crs_track
CREATE PROC Sp_SelectCrsTrack
    @TrackId INT = NULL,  
    @CrsId INT = NULL
AS
BEGIN
    BEGIN TRY
        IF @TrackId IS NOT NULL AND @CrsId IS NOT NULL
        BEGIN
            SELECT track_id, crs_id
            FROM Crs_track
            WHERE track_id = @TrackId AND crs_id = @CrsId;
        END
        -- If only TrackId is provided
        ELSE IF @TrackId IS NOT NULL
        BEGIN
            SELECT track_id, crs_id
            FROM Crs_track
            WHERE track_id = @TrackId;
        END
        -- If only CrsId is provided
        ELSE IF @CrsId IS NOT NULL
        BEGIN
            SELECT track_id, crs_id
            FROM Crs_track
            WHERE crs_id = @CrsId;
        END
        -- If no parameters are provided,
        ELSE
         BEGIN
            PRINT 'Please provide either TrackId or CrsId to perform the selection.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting the records from Crs_track.';
    END CATCH
END;

----------------------------------------
--topic
--insert topic
CREATE PROC Sp_InsertTopic
    @Name NVARCHAR(50),
    @CrsId INT = NULL 
AS
BEGIN
    BEGIN TRY
        INSERT INTO Topic (name, crs_id)
        VALUES (@Name, @CrsId);
        
        PRINT 'Topic successfully inserted.';
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while inserting the topic.';
    END CATCH
END;
----------------------------------------
--update topic
CREATE PROC Sp_UpdateTopic
    @Id INT,
    @Name NVARCHAR(50) = NULL, 
    @CrsId INT = NULL 
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Topic WHERE id = @Id)
        BEGIN
            UPDATE Topic
            SET 
                name = COALESCE(@Name, name), 
                crs_id = @CrsId 
            WHERE id = @Id;

            PRINT 'Topic successfully updated.';
        END
        ELSE
        BEGIN
            PRINT 'Topic does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating the topic.';
    END CATCH
END;

-----------------------------------------
--delete topic
CREATE PROC Sp_DeleteTopic
    @Id INT
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Topic WHERE id = @Id)
        BEGIN
            DELETE FROM Topic
            WHERE id = @Id;

            PRINT 'Topic successfully deleted.';
        END
        ELSE
        BEGIN
            PRINT 'Topic does not exist.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while deleting the topic.';
    END CATCH
END;

----------------------------------------
--select topic

CREATE PROC Sp_SelectTopic
    @Id INT = NULL,     
    @CrsId INT = NULL    
AS
BEGIN
    BEGIN TRY
        -- If both Id and CrsId are provided
        IF @Id IS NOT NULL AND @CrsId IS NOT NULL
        BEGIN
            SELECT id, name, crs_id
            FROM Topic
            WHERE id = @Id AND crs_id = @CrsId;
        END
        -- If only Id is provided
        ELSE IF @Id IS NOT NULL
        BEGIN
            SELECT id, name, crs_id
            FROM Topic
            WHERE id = @Id;
        END
        -- If only CrsId is provided
        ELSE IF @CrsId IS NOT NULL
        BEGIN
            SELECT id, name, crs_id
            FROM Topic
            WHERE crs_id = @CrsId;
        END
        -- If neither Id nor CrsId is provided
        ELSE
        BEGIN
            PRINT 'Please provide either Id or CrsId to perform the selection.';
        END
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while selecting topics.';
    END CATCH
END;
----------------------------------------
SP_r5QuestionAndChoicesinExam
use ITI_ExamSystem
--report 1
create proc SP_r1GetStudentInTrack @trk_id int 
as 
	select s.* 
	from Student s , Track t
	where t.id = @trk_id and t.id = s.track_id 

execute SP_r1GetStudentInTrack @trk_id = 1
----------------------------------------
--report2
--Report that takes the student ID and returns the grades of the student in all courses. %
create proc SP_r2GetStdGradeByStdId @std_id int
as
	select c.name , se.grade
	from Course c , Student s , Student_exam se , Exam e
	where s.id= @std_id and  e.id = se.ex_id and s.id = se.stu_id and c.id = e.crs_id 

execute SP_r2GetStdGradeByStdId @std_id =11
----------------------------------------
--report3
--Report that takes the instructor ID 
--and returns the name of the courses that he teaches and the number of student per course.
create proc SP_r3GetCoursesInsTeach @ins_id int 
as 
	select c.name , count(stu_id) as numOfStudents
	from Instructor i , Course c , Ins_course ic , Student s, Student_crs sc
	where ic.ins_id =@ins_id and c.id = ic.crs_id and i.id = ic.ins_id and s.id = sc.stu_id and c.id= sc.crs_id 
	group by c.name

execute SP_r3GetCoursesInsTeach 3

----------------------------------------
--report4
--Report that takes course ID and returns its topics
create proc SP_r4GetTopicsInCourse @crs_id int 
as 
	select t.name
	from Topic t, Course c
	where c.id=@crs_id  and c.id = t.crs_id

execute SP_r4GetTopicsInCourse 1
----------------------------------------
--report5
--Report that takes exam number and returns the Questions in it and chocies [freeform report]
use ITI_ExamSystem

--
use ITI_ExamSystem
alter proc SP_r5QuestionAndChoicesinExam
@ExamID INT
AS
BEGIN
    SELECT 
		c.name,
        eq.ex_id AS ExamID,
        q.id AS QuestionID,
        q.q_head AS QuestionText,
        STRING_AGG(qc.choice, ', ') AS Choices
    FROM 
        Exam_Questions eq
    INNER JOIN 
        Question q ON eq.q_id = q.id
    LEFT JOIN 
        Question_Choices qc ON q.id = qc.q_id
	INNER JOIN
		Exam e ON e.id = eq.ex_id 
	INNER JOIN
		Course c ON  c.id = e.crs_id
    WHERE 
        eq.ex_id = @ExamID
    GROUP BY 
        eq.ex_id, q.id, q.q_head , c.name
    ORDER BY 
        q.id 
END

--
EXEC SP_r5QuestionAndChoicesinExam @ExamID = 6;


------------------------------------------
--report6
--Report that takes exam number and the student ID then returns the Questions in this exam with the student answers. 
alter PROC SP_r6QuestionAndAnswersinExam
@ex_id INT,
@stu_id INT
AS
BEGIN
    SELECT 
		s.fname +' '+s.lname as fullName,
        q.id AS QuestionID,
        q.q_head AS QuestionText,
		q.model_ans AS ModelAnswer,
        seq.stu_ans AS StudentAnswer
    FROM 
	    Student s
	INNER JOIN
        Student_exam_questions seq ON s.id = seq.stu_id
    INNER JOIN 
        Question q ON seq.q_id = q.id
	
		
    WHERE 
        seq.ex_id = @ex_id 
        AND seq.stu_id = @stu_id;
END

exec SP_r6QuestionAndAnswersinExam @ex_id = 13 , @stu_id =11

--reportsTest
exec SP_r1GetStudentInTrack @trk_id  = 1
--
exec SP_r2GetStdGradeByStdId @std_id = 12
--
exec SP_r3GetCoursesInsTeach @ins_id = 2
--
exec SP_r4GetTopicsInCourse @crs_id = 2
--
exec SP_r5QuestionAndChoicesinExam @ExamID = 6
--
exec SP_r6QuestionAndAnswersinExam @ex_id=13 , @stu_id = 11
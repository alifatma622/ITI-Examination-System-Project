use ITI_ExamSystem
---------------------------
--instructor
-- insert instructor
CREATE PROCEDURE [dbo].[SP_insertInstructor]
    @fname VARCHAR(50),
    @lname VARCHAR(50),
    @city VARCHAR(50),
    @street VARCHAR(100),
    @bdate DATE,
    @phone VARCHAR(25),
    @salary INT
AS
BEGIN
    INSERT INTO Instructor (fname, lname, city, street, bdate, phone, salary)
    VALUES (@fname, @lname, @city, @street, @bdate, @phone, @salary)
END
EXEC SP_insertInstructor 
    'Mostafa', 
    'Helal', 
    'ShipinElkoom', 
    'ITI Street', 
    '2000-12-06',
    '01280165653', 
    30000
----------------------------
--update instructor
CREATE PROCEDURE dbo.UpdateInstructor
    @id INT,
    @fname VARCHAR(50) = NULL,
    @lname VARCHAR(50) = NULL,
    @bdate DATE = NULL,
    @phone VARCHAR(15) = NULL,
	@city varchar(50) = NULL,
	@street varchar(100)=NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE id = @id)
    BEGIN
        UPDATE dbo.Instructor
        SET 
            fname = ISNULL(@fname, fname),
            lname = ISNULL(@lname, lname),
            bdate = ISNULL(@bdate, bdate), 
            phone = ISNULL(@phone, phone),
			city = ISNULL(@city , city),
			street = ISNULL(@street,street)
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor with this ID does not exist.';
    END
END;

----------------------------
--delete instructor
CREATE PROCEDURE dbo.DeleteInstructor
    @id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE id = @id)
    BEGIN
		delete from Instructors_in_track where ins_id = @id
		delete from Ins_course where ins_id = @id
		update Track set track_mgr = NULL
        DELETE FROM dbo.Instructor
        WHERE id = @id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor with this ID does not exist.';
    END
END;

--------------------------------------
--select instructor
CREATE PROCEDURE dbo.SelectInstructor
    @id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Instructor WHERE id = @id)
    BEGIN
		Select * from Instructor where id =@id
    END
    ELSE
    BEGIN
        PRINT 'Instructor with this ID does not exist.';
    END
END;
--
exec SelectInstructor @id = 1
--------------------------------------
--instructor in track
--insert
CREATE PROCEDURE SP_insertInstructorInTrack
    @instructor_id INT,
    @track_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Instructors_in_track WHERE track_id = @track_id AND ins_id = @instructor_id)
    BEGIN
        INSERT INTO dbo.Instructors_in_track (track_id, ins_id)
        VALUES (@track_id, @instructor_id);
    END
    ELSE
    BEGIN
        PRINT 'This instructor is already assigned to this track.';
    END
END;

----------------------------------
--update instructor_in_track
CREATE PROCEDURE dbo.Update_Instructor_in_Track
    @instructor_id INT,
    @track_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Instructor_in_Track WHERE ins_id = @instructor_id AND track_id = @track_id)
    BEGIN
        UPDATE dbo.Instructor_in_Track
        SET track_id = @track_id
        WHERE ins_id = @instructor_id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor in Track record does not exist.';
    END
END;
----------------------------------
--delete instructor_in_track
CREATE PROCEDURE dbo.Delete_Instructor_in_Track
    @instructor_id INT,
    @track_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Instructor_in_Track WHERE ins_id = @instructor_id AND track_id = @track_id)
    BEGIN
        DELETE FROM dbo.Instructor_in_Track
        WHERE ins_id = @instructor_id AND track_id = @track_id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor in Track record does not exist.';
    END
END;
---------------------------------
--select instructor_in_track

CREATE PROCEDURE dbo.SelectInstructorinTrack
    @instructor_id INT = NULL, 
    @track_id INT = NULL
AS
BEGIN
    IF @instructor_id IS NOT NULL AND @track_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Instructors_in_track WHERE ins_id = @instructor_id AND track_id = @track_id)
        BEGIN
            SELECT * FROM dbo.Instructors_in_track WHERE ins_id = @instructor_id AND track_id = @track_id;
        END
        ELSE
        BEGIN
            PRINT 'Instructor in Track record does not exist for the given combination.';
        END
    END
    ELSE IF @instructor_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Instructors_in_track WHERE ins_id = @instructor_id)
        BEGIN
            SELECT * FROM dbo.Instructors_in_track WHERE ins_id = @instructor_id;
        END
        ELSE
        BEGIN
            PRINT 'Instructor record does not exist for the given instructor ID.';
        END
    END
    ELSE IF @track_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Instructors_in_track WHERE track_id = @track_id)
        BEGIN
            SELECT * FROM dbo.Instructors_in_track WHERE track_id = @track_id;
        END
        ELSE
        BEGIN
            PRINT 'Track record does not exist for the given track ID.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Please provide either an instructor ID or a track ID to query.';
    END
END;
--
exec SelectInstructorinTrack @instructor_id = 1
------------------------------------------
--ins_course
--insert ins_course
CREATE PROCEDURE dbo.Insert_Ins_Course
    @instructor_id INT,
    @crs_id INT
AS
BEGIN
    INSERT INTO dbo.Ins_Course (crs_id,ins_id)
    VALUES (@crs_id,@instructor_id )
END;
------------------------------------------
--update ins_course 
alter PROCEDURE dbo.Update_Ins_Course
    @instructor_id INT = NULL,
    @crs_id INT = NULL,
	@newCrsId int
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Ins_Course WHERE ins_id = @instructor_id AND crs_id = @crs_id) and
	 EXISTS (SELECT 1 FROM dbo.Course WHERE id = @newCrsId)
    BEGIN
        UPDATE dbo.Ins_Course
        SET crs_id = ISNULL(@newCrsId , crs_id)
        WHERE ins_id = @instructor_id and crs_id = @crs_id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor in Course record does not exist.';
    END
END;
--
exec Update_Ins_Course @instructor_id = 3 ,@crs_id =2 , @newCrsId =3
------------------------------------------
CREATE PROCEDURE dbo.Delete_Ins_Course
    @instructor_id INT,
    @crs_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Ins_Course WHERE ins_id = @instructor_id AND crs_id = @crs_id)
    BEGIN
        DELETE FROM dbo.Ins_Course
        WHERE ins_id = @instructor_id AND crs_id = @crs_id;
    END
    ELSE
    BEGIN
        PRINT 'Instructor in Course record does not exist.';
    END
END;

--------------------------
--select ins_course
CREATE PROCEDURE dbo.Select_Ins_Course
    @instructor_id INT = NULL, 
    @crs_id INT = NULL
AS
BEGIN
    IF @instructor_id IS NOT NULL AND @crs_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Ins_Course WHERE ins_id = @instructor_id AND crs_id = @crs_id)
        BEGIN
            SELECT * FROM dbo.Ins_Course WHERE ins_id = @instructor_id AND crs_id = @crs_id;
        END
        ELSE
        BEGIN
            PRINT 'Instructor in Course record does not exist for the given combination.';
        END
    END
    ELSE IF @instructor_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Ins_Course WHERE ins_id = @instructor_id)
        BEGIN
            SELECT * FROM dbo.Ins_Course WHERE ins_id = @instructor_id;
        END
        ELSE
        BEGIN
            PRINT 'Instructor record does not exist for the given instructor ID.';
        END
    END
    ELSE IF @crs_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Ins_Course WHERE crs_id = @crs_id)
        BEGIN
            SELECT * FROM dbo.Ins_Course WHERE crs_id = @crs_id;
        END
        ELSE
        BEGIN
            PRINT 'Course record does not exist for the given course ID.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Please provide either an instructor ID or a course ID to query.';
    END
END;
--
exec Select_Ins_Course @instructor_id = 1
-------------------------------------
--student
--insert student
CREATE PROCEDURE dbo.Insert_Student
    @fname VARCHAR(50),
    @lname VARCHAR(50),
    @city VARCHAR(50),
    @street VARCHAR(50),
    @bdate DATE,
    @phone VARCHAR(15),
    @track_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Track WHERE id = @track_id)
    BEGIN
        INSERT INTO dbo.Student (fname, lname, city, street, bdate, phone, track_id)
        VALUES (@fname, @lname, @city, @street, @bdate, @phone, @track_id);
        PRINT 'Student inserted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'The provided track_id does not exist in the Track table.';
    END
END;

--------------------------------
--update Student
CREATE PROCEDURE dbo.Update_Student
    @id INT,
    @fname VARCHAR(50) = NULL, 
    @lname VARCHAR(50) = NULL,
    @city VARCHAR(50) = NULL,
    @street VARCHAR(50) = NULL,
    @bdate DATE = NULL,
    @phone VARCHAR(15) = NULL,
    @track_id INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE id = @id)
    BEGIN
        PRINT 'Student not found.';
        RETURN;
    END

    UPDATE dbo.Student
    SET 
        fname = COALESCE(@fname, fname), 
        lname = COALESCE(@lname, lname),
        city = COALESCE(@city, city),  
        street = COALESCE(@street, street), 
        bdate = COALESCE(@bdate, bdate),  
        phone = COALESCE(@phone, phone),  
        track_id = COALESCE(@track_id, track_id) 
    WHERE id = @id;

    PRINT 'Student information updated successfully.';
END;

----------------------------
--delete student
CREATE PROCEDURE dbo.Delete_Student
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE id = @id)
    BEGIN
        PRINT 'Student not found in the Student table.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @id)
    BEGIN
        DELETE FROM dbo.Student_crs WHERE stu_id = @id;
        PRINT 'Student record deleted from Student_crs table.';
    END
    ELSE
    BEGIN
        PRINT 'Student not found in Student_crs table.';
    END

    IF EXISTS (SELECT 1 FROM dbo.Student_exam WHERE stu_id = @id)
    BEGIN
        DELETE FROM dbo.Student_exam WHERE stu_id = @id;
        PRINT 'Student record deleted from Student_exam table.';
    END
    ELSE
    BEGIN
        PRINT 'Student not found in Student_exam table.';
    END

    IF EXISTS (SELECT 1 FROM dbo.Student_exam_questions WHERE stu_id = @id)
    BEGIN
        DELETE FROM dbo.Student_exam_questions WHERE stu_id = @id;
        PRINT 'Student record deleted from Student_exam_questions table.';
    END
    ELSE
    BEGIN
        PRINT 'Student not found in Student_exam_questions table.';
    END

    DELETE FROM dbo.Student WHERE id = @id;
    PRINT 'Student record deleted from Student table.';
END;
--------------------------------
--select student
CREATE PROCEDURE dbo.Select_Student
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE id = @id)
    BEGIN
        PRINT 'Student not found.';
        RETURN;
    END

    Select * FROM dbo.Student WHERE id = @id;
END;

-----------------------------------------
--stu_crs
--insert stu_crs
CREATE PROCEDURE dbo.Insert_Stu_Crs
    @student_id INT,
    @crs_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE id = @student_id)
    BEGIN
        PRINT 'Student does not exist in the Student table.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Course WHERE id = @crs_id)
    BEGIN
        PRINT 'Course does not exist in the Course table.';
        RETURN;
    END

    INSERT INTO dbo.Student_crs (crs_id, stu_id)
    VALUES (@crs_id, @student_id);

    PRINT 'Student-course record inserted successfully.';
END;

-------------------------------
--update stu_crs
CREATE PROCEDURE dbo.Update_Stu_Crs
    @student_id INT,
    @old_crs_id INT,
    @new_crs_id INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @student_id AND crs_id = @old_crs_id)
	AND EXISTS (SELECT 1 FROM dbo.Course WHERE id = @new_crs_id)
    BEGIN
        UPDATE dbo.Student_crs
        SET crs_id = @new_crs_id
        WHERE stu_id = @student_id AND crs_id = @old_crs_id;
    END
END;

----------------------------------
--delete stu_crs
CREATE PROCEDURE dbo.Delete_Stu_Crs
    @student_id INT = NULL,
    @crs_id INT = NULL
AS
BEGIN
    IF @student_id IS NOT NULL AND @crs_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @student_id AND crs_id = @crs_id)
        BEGIN
            DELETE FROM dbo.Student_crs
            WHERE stu_id = @student_id AND crs_id = @crs_id;

            PRINT 'Student-course record deleted successfully.';
        END
        ELSE
        BEGIN
            PRINT 'Record not found for the specified student and course.';
        END
    END

    ELSE IF @student_id IS NOT NULL AND @crs_id IS NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @student_id)
        BEGIN
            DELETE FROM dbo.Student_crs
            WHERE stu_id = @student_id;

            PRINT 'All courses for the student deleted successfully.';
        END
        ELSE
        BEGIN
            PRINT 'No courses found for the specified student.';
        END
    END
END;

--------------------------------------
--select stu crs
CREATE PROCEDURE dbo.Select_Stu_Crs
    @student_id INT = NULL,
    @crs_id INT = NULL
AS
BEGIN
    IF @student_id IS NOT NULL AND @crs_id IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @student_id AND crs_id = @crs_id)
        BEGIN
            SELECT * 
            FROM dbo.Student_crs
            WHERE stu_id = @student_id AND crs_id = @crs_id;
        END
        ELSE
        BEGIN
            PRINT 'Record not found for the specified student and course.';
        END
    END
    ELSE IF @student_id IS NOT NULL AND @crs_id IS NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE stu_id = @student_id)
        BEGIN
            SELECT * 
            FROM dbo.Student_crs
            WHERE stu_id = @student_id;
        END
        ELSE
        BEGIN
            PRINT 'No courses found for the specified student.';
        END
    END

    ELSE IF @crs_id IS NOT NULL AND @student_id IS NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Student_crs WHERE crs_id = @crs_id)
        BEGIN
            SELECT * 
            FROM dbo.Student_crs
            WHERE crs_id = @crs_id;
        END
        ELSE
        BEGIN
            PRINT 'No students found for the specified course.';
        END
    END

    ELSE
    BEGIN
        PRINT 'Please provide at least one parameter: student_id or crs_id.';
    END
END;
------------------------------------------------------
--Mostafa -> Instructor - instructor in track - ins_course - Student - Stu_crs
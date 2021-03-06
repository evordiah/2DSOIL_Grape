!||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
*                                                                      *
*     2DSOIL  - Numerical model of two-dimensional soil environment    *
*                           for field crops                            *
*                                                                      *
*                              Release 1.1.4                           *
c||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
! TM October 2019                                                      *
! Test of each subroutine                                              *
! Compile, link and run                                                *
!||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||*
      program soil2d_grape
      Include 'public.ins'
      include 'puplant.ins'
      Include 'Puweath.ins'
C      Include 'Nitvar.ins'

      character*132 RunDat
      integer len, status, cycleno
      logical :: finished
      
      RunFile="Run.Dat"
      Call get_command_argument(1, RunDat, len, status)
      if (len.gt.0) then
        RunFile=RunDat
      endif

      Call Initialize()
      Call Get_Grid_and_Boundary()
      cycleno = 0
      finished = .FALSE.
C$$$$$$       if (.not. finished) then
C$$$$$$         print *, "finished=", finished
1        call Synchronizer(finished)

C
C SetSurfaceD --  reading daily weather
C SetSurfaceH --  reading hourly weather

          if ((HourlyWeather+DailyWeather > 1).or.
     &       ((HourlyWeather+DailyWeather) == 0))then
               Write (*,*) "error in weather file type"
          end if

          if (HourlyWeather.eq.1) Call SetSurfaceH()
          if (DailyWeather.eq.1) Call SetSurfaceD()
    
          Call SetTDB()
          Call CROP()
          Call Carbon_Partitioning_New()
          Call Root_diff_New()
          call Root_Mover_New()
          Call WaterUptake_New()
          Call WaterMover_New()
          if (outputSoilYes > 0) then
            Call Output()
          end if

          if(mod(cycleno, 1000) == 0) then
            print *, 'iteration=', cycleno, ' finished=', finished
          end if
          
          cycleno = cycleno + 1
          if (finished) then
            close(81)
            close(82)
            close(83)
            close(84)
            print *, 'iteration=', cycleno, ' finished=', finished
            stop
          end if
        goto 1
          
C$$$$$$          else
C$$$$$$            write(*, *) 'Finished at', time
C$$$$$$          end if
      End program soil2d_grape
